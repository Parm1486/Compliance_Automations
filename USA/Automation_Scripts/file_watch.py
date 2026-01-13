## Purpose: Create a script that looks for a file named daily_position_report.csv

import os
import pandas as pd

# 1. Define where to looks for files
folder_path = "./recon_data/"
target_file = "daily_position_report.csv"

def check_for_new_data():
    full_path = os.path.join(folder_path, target_file)
    
    # 2. Check if the file has arrived
    if os.path.exists(full_path):
        print(f"[ALERT]: New data detected at {full_path}")
        
        # 3. Load the data (First step toward automation)
        data = pd.read_csv(full_path)
        print(f"Summary: Loaded {len(data)} trades for reconciliation.")
        return data
    else:
        print("[WATCHDOG]: No new files detected. Standing by...")
        return None

# Run the check
trades = check_for_new_data()
