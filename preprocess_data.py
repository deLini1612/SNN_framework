import os
import argparse
import numpy as np
import pandas as pd
import scipy.io
from sklearn.model_selection import train_test_split


# =========================
# 6DMG PREPROCESS
# =========================

# max_row is number of row we want to take -> number of time step --> time window
def preprocess_6dmg(data_dir, output_path, test_size=0.2, max_rows = 238):

    folder_path_L = os.path.join(data_dir, "matL")
    folder_path_R = os.path.join(data_dir, "matR")

    mat_arrays = []
    labels = []

    for folder_path in [folder_path_L, folder_path_R]:

        for filename in os.listdir(folder_path):

            if not filename.endswith(".mat"):
                continue

            class_name = filename.split('_')[0]

            if not (class_name.startswith("g") and len(class_name) == 3):
                continue

            label = int(class_name[1:3])

            filepath = os.path.join(folder_path, filename)

            mat = scipy.io.loadmat(filepath)
            data = mat['gest']

            data = np.transpose(data)

            if data.shape[0] < max_rows:
                rows_to_add = max_rows - data.shape[0]
                padding = np.zeros((rows_to_add, data.shape[1]))
                data = np.vstack([data, padding])

            data = data[:, 1:]

            mat_arrays.append(data)
            labels.append(label)

    X = np.stack(mat_arrays)
    y = np.array(labels)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=42
    )

    np.savez(
        output_path,
        X_train=X_train,
        X_test=X_test,
        y_train=y_train,
        y_test=y_test
    )

    print(f"Saved dataset to {output_path}.npz")
    print("X_train shape:", X_train.shape)
    print("y_train shape:", y_train.shape)
    print("X_test shape:", X_test.shape)
    print("y_test shape:", y_test.shape)


# =========================
# EDABK_HGR PREPROCESS
# =========================
def process_blocks(df, label, size=72, stride=36):

    X = []
    y = []

    grouped = df.groupby(df.iloc[:, -1])

    for _, group in grouped:

        blocks = [group.iloc[i:i+size] for i in range(0, len(group), stride)]

        for block in blocks:

            arr = block.values

            if arr.shape == (size, 10):
                X.append(arr[:, :-1])
                y.append(label)

    return X, y


def preprocess_edabk(data_dir, output_path, test_size=0.2):

    files = {
        "down": 0,
        "facedown": 1,
        "shake": 2,
        "turn": 3,
        "up": 4,
        "vibrate": 5
    }

    X = []
    y = []

    for name, label in files.items():

        path = os.path.join(data_dir, f"{name}.csv")
        df = pd.read_csv(path, header=None)
        df["label"] = label

        Xi, yi = process_blocks(df, label)

        X.extend(Xi)
        y.extend(yi)

        print(f"{name} -> {len(Xi)} samples")

    X = np.stack(X)
    y = np.array(y)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=42
    )

    np.savez(
        output_path,
        X_train=X_train,
        X_test=X_test,
        y_train=y_train,
        y_test=y_test
    )

    print(f"Saved dataset to {output_path}.npz")
    print("X_train shape:", X_train.shape)
    print("y_train shape:", y_train.shape)
    print("X_test shape:", X_test.shape)
    print("y_test shape:", y_test.shape)


# =========================
# MAIN
# =========================
def main():

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--dataset",
        type=str,
        required=True,
        choices=["6DMG", "EDABK_HGR"]
    )

    parser.add_argument(
        "--raw_dir",
        type=str,
        default="Software/data/raw"
    )

    parser.add_argument(
        "--processed_dir",
        type=str,
        default="Software/data/processed"
    )

    args = parser.parse_args()
    data_dir = args.raw_dir + "/" + args.dataset
    output_file = args.processed_dir + "/" + args.dataset

    if args.dataset == "6DMG":
        preprocess_6dmg(data_dir, output_file)

    elif args.dataset == "EDABK_HGR":
        preprocess_edabk(data_dir, output_file)


if __name__ == "__main__":
    main()