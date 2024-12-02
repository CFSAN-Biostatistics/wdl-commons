import pytest
import tempfile
import requests
from pathlib import Path
import logging
import json
import os

from WDL.runtime import run, config
from WDL import values_from_json, values_to_json

def use_file(partial_path):
    project = Path(__file__).parent.parent
    pytest_cache = project / ".pytest_cache"
    cached_commons = pytest_cache / "data-commons"
    cached_file = cached_commons / partial_path
    subrepo_commons = project / "data-commons"
    subrepo_file = subrepo_commons / partial_path
    if cached_file.exists():
        yield str(cached_file)
    else:
        cached_file.parent.mkdir(parents=True, exist_ok=True)
        with open(cached_file, "wb"  ) as f:
            try:
                response = requests.get(f"https://raw.githubusercontent.com/CFSAN-Biostatistics/data-commons/{partial_path}")
                response.raise_for_status()
                f.write(response.content)
                yield f.name
            except:
                cached_file.unlink()
                if subrepo_file.exists():
                    yield str(subrepo_file)
                else:
                    raise FileNotFoundError(f"File not found: {partial_path}")

# def run_task(task, inputs):
#     inputs_env = values_from_json(inputs, task.available_inputs, task.required_inputs)
#     cfg = config.Loader(logging.getLogger(__name__))
#     with tempfile.TemporaryDirectory() as tmpdir:
#         _, outputs_env = run(cfg, exe=task, inputs=inputs_env, run_dir=tmpdir)
#     return values_to_json(outputs_env)

def run_task(wdl, task, inputs, mode='rt'):
    "Run a workflow task using miniwdl as a subprocess and return the outputs as a dict"
    from subprocess import run, PIPE
    project = Path(__file__).parent.parent
    pytest_cache = project / ".pytest_cache"
    curr = os.getcwd()
    with tempfile.NamedTemporaryFile(dir=pytest_cache, mode='wt', delete=False) as f:
        json.dump(inputs, f)
    try:
        with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmpdir:
            
            process = run([
                                "miniwdl", 
                                "run", 
                                wdl,
                                '-i', 
                                f.name,
                                '--verbose',
                                '--task', 
                                task.name, 
                                '-d',
                                tmpdir,
                        ], 
                            stdout=PIPE, 
                            check=True)
            process.check_returncode()
            output = json.loads(process.stdout)['outputs']
            for key, value in output.items():
                try:
                    if Path(value).exists():
                        try:
                            with open(value, mode) as f:
                                output[key] = f.read()
                        except UnicodeDecodeError:
                            with open(value, "rb") as f:
                                output[key] = f.read()
                except:
                    pass # do nothing
        return output
    finally: # miniwdl breaks the shell when it fails, try and fix it
        os.chdir(curr)
    
