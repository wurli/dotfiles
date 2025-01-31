# https://github.com/databricks/databricks-vscode/blob/036002573396c56c1b1cf2b89fc0c06c659a7bf6/packages/databricks-vscode/resources/python/stubs/__builtins__.pyi#L5

from databricks.sdk.runtime import *  # noqa: F403
from pyspark.sql.session import SparkSession
from pyspark.sql.functions import udf as U
from pyspark.sql.context import SQLContext

udf = U
spark: SparkSession
sc = spark.sparkContext
sqlContext: SQLContext
sql = sqlContext.sql
table = sqlContext.table
getArgument = dbutils.widgets.getArgument  # noqa: F405

def displayHTML(html): ...

def display(input=None, *args, **kwargs): ...


