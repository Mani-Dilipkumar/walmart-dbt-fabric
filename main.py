import os
import sys
import subprocess
from pathlib import Path

env_path = Path(__file__).parent / ".env"

env = os.environ.copy()
with open(env_path) as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith("#"):
            key, value = line.split("=", 1)
            env[key] = value

dbt_args = ['dbt'] + sys.argv[1:] if len(sys.argv) > 1 else ['dbt', 'debug']
subprocess.run(dbt_args, env=env)