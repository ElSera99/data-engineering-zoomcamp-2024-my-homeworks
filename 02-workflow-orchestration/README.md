# Introduction

In order to deploy the infrastructure to the GCP cloud, Mage already provides the templates to deploy in different cloud providers, templates for **Terraform GCP** can be found in:
https://github.com/mage-ai/mage-ai-terraform-templates

Terraform installer can be found in, remember to **download Terraform inside the folder where the GCP templates are**:
https://developer.hashicorp.com/terraform/install

Finally, to deploy to GCP using Terraform you need to have an active connection in **gcloud CLI** to GCP, the installer for gcloud CLI can be found in:
https://cloud.google.com/sdk/docs/install

# Configure gcloud CLI
After installer via GUI or installer via package manager, is necessary to configure the connection with your GCP account and current proyect, in order to do so, open a CLI and run the following command:
```shell
gcloud auth application-default login
```
This will open a tab in web browser asking for authentication, sign in into your account and allow permissions.

Now, create a **service account with owner permissions** and create a **JSON key** for this user, **move this key in a location inside the folder of the Terraform templates to deploy Mage**.

# Deploy with Terraform
After downloading templates, make sure to **modify the following Terraform variables** to set your own identification values:
```JSON
variable "project_id" {
  type        = string
  description = "The name of the project"
  default     = "<ID_OF_YOUR_PROJECT>"
}
```
```JSON
variable "database_user" {
    type = string
    description = "The username of the Postgres database."
    default= "<YOUR_DATABASE_USER>"
}
```
Now, add the **credentials location** to your **provider block** inside the **terraform file main.tf** as:
```JSON
provider "google" {
  credentials = file("<PATH_TO_CREDENTIAL_JSON>")
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
```
After this, inside your **Terraform templates folder**, open a CLI and run:
```shell
terraform init
```
This should run the **Terraform backend**, after this if no error appears, try to format the files by running:
```shell
terraform fmt
```
Now review your resources to be created by running:
```shell
terraform plan
```

To **deploy Mage**, run:
```shell
terraform apply
```

After this, a promtp **asking for your dabatase password** is shown, write a password you can remember to enter your database.

Finally, a new prompt asking for **confirmation to deploy** the resourcers, in this prompt **type yes** to deploy the entire infrastructure.

If nothing goes wrong, at the end of the resources deployment a variable will be printed that represents the **ip where Mage can be accessed.**

# Homework - Local
Homework description for this module can be found in here:
https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2024/02-workflow-orchestration/homework.md

And data used can be found in the following link:
https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/green/download

Where links for data in the last quarter of 2020 are:
- https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-10.csv.gz
- https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-11.csv.gz
- https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-12.csv.gz

## Load Data
In order to load data, we can make use of **pandas** method ````pandas.read_csv`` inside this method we can **directly insert the URL of the CSV file**, also if they are compressed we can directly read the files by setting the parameter ````compression``, an example is as follows:
```python
url = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-10.csv.gz"
df_tmp = pd.read_csv(element, compression="gzip", low_memory=False)

```
## Trasform Data
For this case, we are asking to transform data as the following requirements:
- Set all columns in snake case.
- Create a column called ```lpep_pickup_date``` by converting ```lpep_pickup_datetime``` to a date.
- Remove rows where the passenger count is equal to 0 and the trip distance is equal to zero.

### Set all columns to snake case
We can take the columns from the data frame as:
```python
columns = df.columns
```
We can iterate and transform over this column by appending ```str``` transfomations as:
```python
df.columns = (df.columns
              .str.lower()
              .str.replace(" ", "_")
              .str.replace("id","_id")
              .str.replace("pul","pu_l")
              .str.replace("dol","do_l")
)
```
The usage of the **vectorized string functions** ```str``` allow to treat the columns as any other string object.

### Create a column called ```lpep_pickup_date```
Same as with the columns, we can make datetime ```dt``` transformations as follows:

```python
df["lpep_pickup_date"] = df["lpep_pickup_datetime"].dt.date
```

The usage of the **accessor object** ```dt``` allows to use the properties of datatime objects for pandas Series.

### Remove rows where the passenger count is equal to 0 and the trip distance is equal to zero.
This can be easily done by filtering by columns in a dataframe as follows:
```python

df_filtered = df[(df["passenger_count"] > 0) & (df["trip_distance"] > 0)]
```

## Export Data
To export data to a **parquet** format we need to use the ```PyArrow``` python package.

We first need to create a ```table``` that is an object compatible to ```PyArrow``` that comes from a data frame, this can be done as:
```python
import pyarrow as pa
table = pa.Table.from_pandas(df)
```

Now, to write into a parquet file, we need to use the ```parquet``` object from ```PyArrow``` as follows:
```python
import pyarrow.parquet as pq
pq.write_to_dataset(
	table,
	root_path="./green_taxi_data",
	partition_cols = ['lpep_pickup_date']
    )
```

All of the content for this process can be found in the jupyter notebook called *homework_local.ipynb*

# Homework - Mage in GCP