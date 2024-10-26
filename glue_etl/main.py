import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.job import Job

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

dyf_raw_base = glueContext.create_dynamic_frame_from_catalog(database="baofd-db", table_name="fd-base_dataset")

dyf_raw_base_col_removed = dyf_raw_base.drop_fields(paths=['month', 'zip_count_4w', 'velocity_6h', 'velocity_24h',
                                        'velocity_4w', 'device_fraud_count', 'source'], transformation_ctx='drop_column')

conn = {
    "dbtable": "public.baofd_data",
    "database": "dev"
}

redshift_res = glueContext.write_dynamic_frame_from_jdbc_conf(
    frame=dyf_raw_base_col_removed,
    catalog_connection="redshift_database",
    connection_options=conn
)