#!/usr/bin/env python3
"""Small dependency-free training job for the ROSIE Slurm tutorial.

This ipushs intentionally a teaching example rather than a production image model.
It trains one SELU neuron to reconstruct clean values from noisy synthetic
values, prints progress for the Slurm output file, and saves a JSON summary.
"""

import argparse
import json
import math
import os
import random
import socket
import time


SELU_ALPHA = 1.6732632423543772
SELU_SCALE = 1.0507009873554805


def selu(value):
    if value > 0.0:
        return SELU_SCALE * value
    return SELU_SCALE * SELU_ALPHA * (math.exp(value) - 1.0)


def selu_derivative(value):
    if value > 0.0:
        return SELU_SCALE
    return SELU_SCALE * SELU_ALPHA * math.exp(value)


def calculate_loss(prediction, target, loss_function):
    difference = prediction - target
    if loss_function == "mae":
        return abs(difference)
    return difference * difference


def make_dataset(number_of_samples, seed):
    random_generator = random.Random(seed)
    dataset = []

    for _ in range(number_of_samples):
        clean_value = random_generator.uniform(-1.0, 1.0)
        noisy_value = clean_value + random_generator.gauss(0.0, 0.08)
        dataset.append((noisy_value, clean_value))

    random_generator.shuffle(dataset)
    return dataset


def evaluate(dataset, weight, bias, loss_function):
    total_loss = 0.0
    for noisy_value, clean_value in dataset:
        prediction = selu(weight * noisy_value + bias)
        total_loss += calculate_loss(prediction, clean_value, loss_function)
    return total_loss / len(dataset)


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Run a small dependency-free SELU reconstruction demo."
    )
    parser.add_argument("--loss_function", choices=("mse", "mae"), default="mse")
    parser.add_argument("--optimizer", choices=("adam", "sgd"), default="adam")
    parser.add_argument("--epochs", type=int, default=10)
    parser.add_argument("--num_images", type=int, default=3600)
    parser.add_argument("--split", type=float, default=0.8)
    parser.add_argument("--exp_name", default="selu_reconstruction_demo")
    parser.add_argument("--batch_size", type=int, default=64)
    parser.add_argument("--seed", type=int, default=42)
    arguments = parser.parse_args()

    if arguments.epochs < 1:
        parser.error("--epochs must be at least 1")
    if arguments.num_images < 2:
        parser.error("--num_images must be at least 2")
    if not 0.0 < arguments.split < 1.0:
        parser.error("--split must be between 0 and 1")
    if arguments.batch_size < 1:
        parser.error("--batch_size must be at least 1")

    return arguments


def main():
    arguments = parse_arguments()
    start_time = time.time()
    dataset = make_dataset(arguments.num_images, arguments.seed)
    split_index = int(len(dataset) * arguments.split)
    training_data = dataset[:split_index]
    validation_data = dataset[split_index:]
    shuffle_generator = random.Random(arguments.seed + 1)

    weight = 0.5
    bias = 0.1
    learning_rate = 0.01 if arguments.optimizer == "adam" else 0.05

    first_moment_weight = 0.0
    first_moment_bias = 0.0
    second_moment_weight = 0.0
    second_moment_bias = 0.0
    adam_step = 0
    beta_one = 0.9
    beta_two = 0.999
    epsilon = 1e-8

    print("Starting experiment: {0}".format(arguments.exp_name), flush=True)
    print("Host: {0}".format(socket.gethostname()), flush=True)
    print(
        "Allocated CUDA device(s): {0}".format(
            os.environ.get("CUDA_VISIBLE_DEVICES", "not reported")
        ),
        flush=True,
    )
    print(
        "Samples: {0} training, {1} validation | Optimizer: {2} | Loss: {3}".format(
            len(training_data),
            len(validation_data),
            arguments.optimizer,
            arguments.loss_function,
        ),
        flush=True,
    )

    for epoch in range(1, arguments.epochs + 1):
        shuffle_generator.shuffle(training_data)

        for batch_start in range(0, len(training_data), arguments.batch_size):
            batch = training_data[
                batch_start : batch_start + arguments.batch_size
            ]
            weight_gradient = 0.0
            bias_gradient = 0.0

            for noisy_value, clean_value in batch:
                activation_input = weight * noisy_value + bias
                prediction = selu(activation_input)
                difference = prediction - clean_value

                if arguments.loss_function == "mae":
                    prediction_gradient = 1.0 if difference > 0.0 else -1.0
                else:
                    prediction_gradient = 2.0 * difference

                activation_gradient = (
                    prediction_gradient * selu_derivative(activation_input)
                )
                weight_gradient += activation_gradient * noisy_value
                bias_gradient += activation_gradient

            weight_gradient /= len(batch)
            bias_gradient /= len(batch)

            if arguments.optimizer == "adam":
                adam_step += 1
                first_moment_weight = (
                    beta_one * first_moment_weight
                    + (1.0 - beta_one) * weight_gradient
                )
                first_moment_bias = (
                    beta_one * first_moment_bias
                    + (1.0 - beta_one) * bias_gradient
                )
                second_moment_weight = (
                    beta_two * second_moment_weight
                    + (1.0 - beta_two) * weight_gradient * weight_gradient
                )
                second_moment_bias = (
                    beta_two * second_moment_bias
                    + (1.0 - beta_two) * bias_gradient * bias_gradient
                )

                corrected_first_weight = first_moment_weight / (
                    1.0 - beta_one**adam_step
                )
                corrected_first_bias = first_moment_bias / (
                    1.0 - beta_one**adam_step
                )
                corrected_second_weight = second_moment_weight / (
                    1.0 - beta_two**adam_step
                )
                corrected_second_bias = second_moment_bias / (
                    1.0 - beta_two**adam_step
                )

                weight -= (
                    learning_rate
                    * corrected_first_weight
                    / (math.sqrt(corrected_second_weight) + epsilon)
                )
                bias -= (
                    learning_rate
                    * corrected_first_bias
                    / (math.sqrt(corrected_second_bias) + epsilon)
                )
            else:
                weight -= learning_rate * weight_gradient
                bias -= learning_rate * bias_gradient

        training_loss = evaluate(
            training_data, weight, bias, arguments.loss_function
        )
        validation_loss = evaluate(
            validation_data, weight, bias, arguments.loss_function
        )
        print(
            "Epoch {0:>2}/{1}: train_loss={2:.6f}, validation_loss={3:.6f}".format(
                epoch, arguments.epochs, training_loss, validation_loss
            ),
            flush=True,
        )

    results = {
        "experiment": arguments.exp_name,
        "host": socket.gethostname(),
        "optimizer": arguments.optimizer,
        "loss_function": arguments.loss_function,
        "epochs": arguments.epochs,
        "training_samples": len(training_data),
        "validation_samples": len(validation_data),
        "final_training_loss": training_loss,
        "final_validation_loss": validation_loss,
        "learned_weight": weight,
        "learned_bias": bias,
        "elapsed_seconds": time.time() - start_time,
    }
    results_file = "{0}_results.json".format(arguments.exp_name)
    with open(results_file, "w", encoding="utf-8") as output_file:
        json.dump(results, output_file, indent=2)

    print("Finished successfully.", flush=True)
    print("Results saved to {0}".format(results_file), flush=True)


if __name__ == "__main__":
    main()
