# Introduction
As part of the Data Engineering Zoomcamp from DataTalks, in this section for Batch Processing using PySpark solve for the following homework questionnaire:

https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2024/05-batch/homework.md

# Setup

- Install Spark
- Run PySpark
- Create a local spark session

# Setup Solution

First, we need to setup a VM on Cloud Engine from, after setup in GCP. 

**Install Spark**: To install spark, we can make use fo the following bash script that downloads the neeeded binaries and creates a **`.bashrc`** file to **`source`**:

```bash
# Create spark directory
cd ~
mkdir spark
cd spark

# Create .bashrc file
touch .bashrc

# Get Java SDK
wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
tar xzfv openjdk-11.0.2_linux-x64_bin.tar.gz
rm openjdk-11.0.2_linux-x64_bin.tar.gz

# Create environment variables for Java
echo 'export JAVA_HOME="${HOME}/spark/jdk-11.0.2"' >> .bashrc
echo 'export PATH="${JAVA_HOME}/bin:${PATH}"' >> .bashrc

# Add blanck space
echo >> .bashrc

# Get Spark
wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz
tar xzfv spark-3.3.2-bin-hadoop3.tgz
rm spark-3.3.2-bin-hadoop3.tgz

# Create environment variables for Spark
echo 'export SPARK_HOME="${HOME}/spark/spark-3.3.2-bin-hadoop3"' >> .bashrc
echo 'export PATH="${SPARK_HOME}/bin:${PATH}"' >> .bashrc

# Add blank space
echo >> .bashrc

# Set variables for PySpark
echo 'export PYTHONPATH="${SPARK_HOME}/python/:$PYTHONPATH"' >> .bashrc
echo 'export PYTHONPATH="${SPARK_HOME}/python/lib/py4j-0.10.9.5-src.zip:$PYTHONPATH"' >> .bashrc

```

Now, make usage of **jupyter lab** to create a spark session, after accessing to the Jupyter Lab Web GUI, import the libraries and create the session as:

```python
import pyspark
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()
```

# Questions

## Question 1

**Install Spark and PySpark**

- Execute spark.version.

What's the output?

After the creation of the **`SparkSession`**, run the command **`spark.version`** and the output should look like:

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/fb4c62dd-8761-4eee-86c2-b71024ca4cf4/c16956b2-6d6e-4ccd-a6bf-af971f7ea629/Untitled.png)

**`3.3.2`**

## Question 2

**FHV October 2019**

Read the October 2019 FHV into a Spark Dataframe with a schema as we did in the lessons.

Repartition the Dataframe to 6 partitions and save it to parquet.

What is the average size of the Parquet (ending with .parquet extension) Files that were created (in MB)? Select the answer which most closely matches.

- 1MB
- **`6MB`**
- 25MB
- 87MB

## Question 2 Solution

Executed as:

```python
!wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/fhv/fhv_tripdata_2019-10.csv.gz
!gunzip fhv_tripdata_2019-10.csv.gz

import pyspark
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()
    
from pyspark.sql import types
schema = types.StructType(
	[types.StructField('dispatching_base_num',  types.StringType(), True), 
	types.StructField('pickup_datetime', types.TimestampType(), True), 
	types.StructField('dropOff_datetime', types.TimestampType(), True), 
	types.StructField('PULocationID', types.IntegerType(), True), 
	types.StructField('DOLocationID', types.IntegerType(), True), 
	types.StructField('SR_Flag', types.StringType(), True),
    types.StructField('Affiliated_base_number', types.StringType(), True)]
)
    
df = spark.read.csv('fhv_tripdata_2019-10.csv')
df = df.repartition(6)
df.write.parquet('data/fhv/2019/10/')

!ls -lha data/fhv/2019/10/
```

## Question 3

**Count records**

How many taxi trips were there on the 15th of October?

Consider only trips that started on the 15th of October.

- 108,164
- 12,856
- 452,470
- **`62,610`**

## Question 3 Solution

Executed as:

```python
from pyspark.sql import functions as F

df = spark.read.parquet('data/fhv/2019/10/')
df_15_oct = df.filter(F.to_date(df.pickup_datetime) == "2019-10-15")

df_15_oct.count()
```

## Question 4

**Longest trip for each day**

What is the length of the longest trip in the dataset in hours?

- **`631,152.50 Hours`**
- 243.44 Hours
- 7.68 Hours
- 3.32 Hours

## Question 4 Solution

Executed as:

```python
from pyspark.sql import functions as F

df_hours = df \
        .withColumn('date_diff',(F.unix_timestamp("dropOff_datetime") - F.unix_timestamp("pickup_datetime"))/3600) \
        .select('date_diff')

df_hours.sort(df_hours.date_diff.desc()).show(1)
```

## Question 5

**User Interface**

Spark’s User Interface which shows the application's dashboard runs on which local port?

- 80
- 443
- 4040
- **`8080`**

## Question 6

**Least frequent pickup location zone**

Load the zone lookup data into a temp view in Spark

[Zone Data](https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv)

Using the zone lookup data and the FHV October 2019 data, what is the name of the LEAST frequent pickup location Zone?

- East Chelsea
- **`Jamaica Bay`**
- Union Sq
- Crown Heights North

## Question 6 Solution

Executed as:

```python
!wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
df_zones = spark.read.option('header', True).csv('taxi_zone_lookup.csv')

df_pulocation = df.select('PULocationID')

df_joined = df_pulocation \
.join(df_zones, df_pulocation.PULocationID == df_zones.LocationID) \
.groupBy(df_zones.Zone).count() \
.sort(F.col('count').asc())

df_joined.show(1)
```