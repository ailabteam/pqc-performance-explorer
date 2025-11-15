import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import argparse
import os

def plot_benchmarks(csv_file, output_dir, type):
    try:
        df = pd.read_csv(csv_file)
    except FileNotFoundError:
        print(f"Error: CSV file not found at {csv_file}. Please run parse_results.py first.")
        return
    
    if df.empty:
        print(f"Warning: The CSV file {csv_file} is empty. No chart will be generated.")
        return

    for col in df.columns:
        if '_ns' in col:
            df[col.replace('_ns', '_us')] = df[col] / 1000
            df.drop(col, axis=1, inplace=True)
    
    df.sort_values(by=df.columns[1], ascending=True, inplace=True)

    plt.style.use('seaborn-v0_8-whitegrid')
    
    if type == 'kem':
        operations = ['keypair_us', 'encaps_us', 'decaps_us']
        title = 'Performance of PQC Key Encapsulation Mechanisms (KEMs)'
    else:
        operations = ['keypair_us', 'sign_us', 'verify_us']
        title = 'Performance of PQC Digital Signature Schemes'

    ax = df.plot(x='algorithm', y=operations, kind='bar', figsize=(18, 10), rot=45)

    plt.title(title, fontsize=20)
    plt.xlabel('Algorithm', fontsize=14)
    plt.ylabel('Average Time (microseconds) - Log Scale', fontsize=14)
    ax.set_yscale('log')
    plt.xticks(rotation=45, ha='right')
    plt.legend(title='Operation')
    plt.grid(True, which="both", ls="--")
    plt.tight_layout()

    output_filename = os.path.join(output_dir, f'{type}_performance_comparison.png')
    plt.savefig(output_filename, dpi=600, bbox_inches='tight')
    
    print(f"Chart saved to {output_filename}")
    plt.close()

def main():
    parser = argparse.ArgumentParser(description="Visualize PQC benchmark results from a CSV file.")
    parser.add_argument("input_csv", help="Path to the benchmark .csv file.")
    parser.add_argument("--type", choices=['kem', 'sig'], required=True, help="Type of benchmark: 'kem' or 'sig'.")
    
    args = parser.parse_args()
    
    output_directory = "figures"
    os.makedirs(output_directory, exist_ok=True)
    
    plot_benchmarks(args.input_csv, output_directory, args.type)

if __name__ == "__main__":
    main()
