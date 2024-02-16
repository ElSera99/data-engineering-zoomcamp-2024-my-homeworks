# Questions
## Question 1. What is the sum of the outputs of the generator for limit = 5?

- 10.234
- 7.892
- ```8.382```
- 9.123

## Question 2. What is the 13th number yielded by the generator?
- 4.236
- ```3.605```
- 2.345
- 5.678

## Question 3. Append the 2 generators. After correctly appending the data, calculate the sum of all ages of people.
- ```353```
- 365
- 378
- 390

## Question 4. Merge the 2 generators using the ID column. Calculate the sum of ages of all the people loaded as described above.
- 215
- ```266```
- 241
- 258

# Notes on Execution
## Generators

https://www.youtube.com/watch?v=tmeKsb2Fras

A generator is like a function that returns a list of values, except that with each call the function returns a single element and pauses, reassuming on next element with the next call.

A generator is defined like a function, but instead of using **`return`** as output, make use of **`yield`** keyword:

```python
def get_value():
	yield 1
	yield 2
	yield 3
```

```python
def get_value(limit):
	for i in range(limit):
		yield i * i
```

Calling the generator does not run the generator, in order to obtain a value from it, you need to use the built-in function **`next()`**, this will return the next element in the **`yield`** instruction or will exhaust the elements returned.

```python
# Create a generator
elements = get_values(6)

# Get value 
value = next(elements)
```

This is commonly used with **for loops** to extract data.

The usage of generators is very memory effective since the entire data is not fully stored in memory, but only the current state of execution.

Iterators also possess **generator comprehension** with the exact same syntax as **list comprehension:**

```python
squares = (x*x for x in range(6))
print(next(squares))
```

With the usage of **generator comprehension** multiple functions can be used with them as:

```python
result = sum((x*x for x in range(6)))
print(result)
```

### Example: Read from File

Can iterate line by line from a file.

```python
with open("nums.txt") as file:
	nums = (row.partition("#")[0].rstrip() for row in file)
```

### Example: Lazy Iterator

Can return infinite values as they are called.

```python
def powers_of_two()
	x = 1
	while True:
		yield x
		x *= 2
```

## DLT Pipelines

**DLT** can be used to store data in a **DuckDB** database in the same pipeline creation

### Declare Pipeline

A simple pipeline can be declared as:

```python
dlt.pipeline()
```

This simple pipeline must contain the following arguments.

- **`pipeline_name`**: For this scenario, will set the name of the **DuckBD** database to store, for other cases this will only give a name to the running pipeline.
- **`destination`**: Will set the type of destination for the data, such a database, file type of cloud storage.
- **`dataset_name`**: Will set the name of the dataset

For this scenario, we can declare our pipeline as:

```python
import dlt

pipeline = dlt.pipeline(pipeline="HW", destination="duckdb", dtaset_name="hw")
```

### Run Pipeline

We can run the pipeline as:

```python
pipeline.run()
```

The **`run()`** method must contain the following arguments:

- **`data`**: This is the data to be stored, does not need to be matched to a key pair value, can pass as a single argument
- **`table_name`**: Name of the table to be created or used
- **`write_disposition`**: This indicates the type of writing data to do, such as:
    - **`append`**: will append data at the end of the table
    - **`merge`**: will replace values if updated, needs a **`primary_key`** declared
- **`primary_key`**: The primary key must be defined in order to store data in a database

For this scenario, we can run our pipeline as:

```python
info = pipeline.run(data1, table_name="users", write_disposition="append", primary_key="ID")
```

The **`info`** variable will return the status of the **`run`** operation.