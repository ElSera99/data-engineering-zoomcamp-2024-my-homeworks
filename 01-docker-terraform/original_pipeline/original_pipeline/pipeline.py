# Import libraries
from os import environ, system
from time import time
import argparse

from sqlalchemy import create_engine
import pandas as pd

def main(params):
    # Load values from parser
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    dbname = params.dbname
    table_name = params.table_name
    csv_name = params.csv_name
    csv_url = params.csv_url

    # Create engine
    engine = create_engine(f"postgresql://{user}:{password}@{host}:{port}/{dbname}")

    # Download the CSV
    system(f"wget {csv_url} -O csv/{csv_name}.csv.gz")
    system(f"gunzip csv/{csv_name}.csv.gz")
    
    # Creation of iterator
    df_iter = pd.read_csv(f"./csv/{csv_name}.csv", iterator=True, chunksize=10000)

    # Create table in database
    df = next(df_iter)  # Initialize iterator
    df["tpep_pickup_datetime"] = pd.to_datetime(df["tpep_pickup_datetime"]) # Datetime 
    df["tpep_dropoff_datetime"] = pd.to_datetime(df["tpep_dropoff_datetime"])
    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')  # Only headers

        # Insert data
    print("Starting data transfer to database")
    start_insert = time()
    
    while True:
        try:        
            start_time = time()
            
            df["tpep_pickup_datetime"] = pd.to_datetime(df["tpep_pickup_datetime"])
            df["tpep_dropoff_datetime"] = pd.to_datetime(df["tpep_dropoff_datetime"])
            
            df.to_sql(name='yellow_taxi_data', con=engine, if_exists='append')
            
            end_time = time()
            delta_time = end_time - start_time
            
            print(f"{len(df)} registries transfered in {delta_time:.3f} seconds")
            
            df = next(df_iter)
        except:
            break
    
    end_insert = time()
    delta_insert = end_insert - start_insert
    
    print(f"Data transfer ended")
    print(f"total time elapsed: {delta_insert:.3f}")



if __name__ == "__main__":
    # Create parser
    parser = argparse.ArgumentParser(description="Database credentials and CSV file selection")

    # Set parameters
    parser.add_argument("--user", help="User of postgres DBMS")
    parser.add_argument("--password", help="Password of postgres DBMS")
    parser.add_argument("--host", help="Host IP of postgres DBMS")
    parser.add_argument("--port", help="Port of postgres DBMS")
    parser.add_argument("--dbname", help="Database name to use")
    parser.add_argument("--table_name", help="Table name to use")
    parser.add_argument("--csv_name", help="CSV file name")
    parser.add_argument("--csv_url", help="CSV Location of URL")
    
    # Load values from parser
    args = parser.parse_args()

    main(args)






