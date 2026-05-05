#!/usr/bin/env bash
set -euo pipefail

PYTHON_VERSION="${PYTHON_VERSION:-3.12}"
VENV_PATH="${VENV_PATH:-$HOME/.venv}"

echo "Installing Python data science stack via uv (${PYTHON_VERSION}) into ${VENV_PATH}..."

if [ ! -d "$VENV_PATH" ]; then
  uv venv --python "${PYTHON_VERSION}" "${VENV_PATH}"
fi

UV="uv pip install --python ${VENV_PATH}/bin/python"

# Core data science
$UV \
  numpy pandas scipy scikit-learn statsmodels \
  matplotlib seaborn plotly bokeh altair

# Data engineering
$UV \
  duckdb polars pyarrow "dask[complete]" \
  sqlalchemy psycopg2-binary pymongo redis

# Deep learning
$UV \
  torch torchvision torchaudio \
  "jax[cpu]" flax optax

# LLM stack
$UV \
  transformers datasets tokenizers huggingface-hub \
  accelerate peft trl \
  langchain langchain-community langchain-core \
  openai anthropic \
  llama-index sentence-transformers \
  chromadb faiss-cpu tiktoken

# Bayesian: Pyro, NumPyro, PyMC
$UV \
  pyro-ppl numpyro arviz bambi pymc

# MLOps
$UV \
  mlflow wandb optuna

# Jupyter & utilities
$UV \
  jupyter jupyterlab ipywidgets \
  tqdm rich typer "pydantic>=2" \
  httpx requests python-dotenv loguru click

echo "Python packages installed into ${VENV_PATH}."
echo "Add to your shell: export PATH=\"${VENV_PATH}/bin:\$PATH\""
