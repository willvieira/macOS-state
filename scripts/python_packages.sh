#!/usr/bin/env bash
set -euo pipefail

echo "Installing Python data science stack via uv..."

UV="uv pip install --system"

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

echo "Python packages installed."
