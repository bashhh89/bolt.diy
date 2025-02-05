# Base image
ARG BASE=node:20.18.0
FROM ${BASE} AS base
WORKDIR /app
# Install git and clone the repository to access package.json, pnpm-lock.yaml, and pre-start.cjs
RUN apt-get update && apt-get install -y git && \
    git clone https://github.com/stackblitz-labs/bolt.diy.git /tmp/bolt.diy && \
    ls -alh /tmp/bolt.diy
# Copy the necessary files from the cloned repository
RUN cp /tmp/bolt.diy/package.json /app/package.json && \
    cp /tmp/bolt.diy/pnpm-lock.yaml /app/pnpm-lock.yaml && \
    cp /tmp/bolt.diy/pre-start.cjs /app/pre-start.cjs && \
    ls -alh /app
# Install dependencies (this step is cached as long as the dependencies don't change)
RUN npm install -g corepack && \
    corepack enable pnpm && \
    pnpm install

# *** ADDED NODE_MODULES LISTING HERE ***
RUN echo "--- Listing node_modules directory ---" && \
    ls -alh node_modules && \
    echo "--- Checking for @remix-run/dev in node_modules ---" && \
    ls -alh node_modules/@remix-run/dev && \
    echo "--- Checking for vite in node_modules ---" && \
    ls -alh node_modules/vite && \
    echo "--- End of node_modules listing ---"

# *** ADDED FILE CHECK HERE - vite.config.ts ***
RUN echo "--- Checking for vite.config.ts in /app directory ---" && ls -alh /app/vite.config.ts && echo "--- End of vite.config.ts check ---"

# Copy the rest of your app's source code
COPY . .
# Expose the port the app runs on
EXPOSE 5173
# Production image
FROM base AS bolt-ai-production
# Define environment variables with default values or let them be overridden
ARG GROQ_API_KEY
ARG HuggingFace_API_KEY
ARG OPENAI_API_KEY
ARG ANTHROPIC_API_KEY
ARG OPEN_ROUTER_API_KEY
ARG GOOGLE_GENERATIVE_AI_API_KEY
ARG OLLAMA_API_BASE_URL
ARG OPENAI_LIKE_API_BASE_URL
ARG DEEPSEEK_API_KEY
ARG OPENAI_LIKE_API_KEY
ARG TOGETHER_API_KEY
ARG TOGETHER_API_BASE_URL
ARG HYPERBOLIC_API_KEY
ARG HYPERBOLIC_API_BASE_URL
ARG MISTRAL_API_KEY
ARG COHERE_API_KEY
ARG LMSTUDIO_API_BASE_URL
ARG XAI_API_KEY
ARG PERPLEXITY_API_KEY
ARG AWS_BEDROCK_CONFIG
ARG VITE_LOG_LEVEL=debug
ARG DEFAULT_NUM_CTX
ENV WRANGLER_SEND_METRICS=false \
    GROQ_API_KEY=${GROQ_API_KEY} \
    HuggingFace_API_KEY=${HuggingFace_API_KEY} \
    OPENAI_API_KEY=${OPENAI_API_KEY} \
    ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY} \
    OPEN_ROUTER_API_KEY=${OPEN_ROUTER_API_KEY} \
    GOOGLE_GENERATIVE_AI_API_KEY=${GOOGLE_GENERATIVE_AI_API_KEY} \
    OLLAMA_API_BASE_URL=${OLLAMA_API_BASE_URL} \
    OPENAI_LIKE_API_BASE_URL=${OPENAI_LIKE_API_BASE_URL} \
    DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY} \
    OPENAI_LIKE_API_KEY=${OPENAI_LIKE_API_KEY} \
    TOGETHER_API_KEY=${TOGETHER_API_KEY} \
    TOGETHER_API_BASE_URL=${TOGETHER_API_BASE_URL} \
    HYPERBOLIC_API_KEY=${HYPERBOLIC_API_KEY} \
    HYPERBOLIC_API_BASE_URL=${HYPERBOLIC_API_BASE_URL} \
    MISTRAL_API_KEY=${MISTRAL_API_KEY} \
    COHERE_API_KEY=${COHERE_API_KEY} \
    LMSTUDIO_API_BASE_URL=${LMSTUDIO_API_BASE_URL} \
    XAI_API_KEY=${XAI_API_KEY} \
    PERPLEXITY_API_KEY=${PERPLEXITY_API_KEY} \
    AWS_BEDROCK_CONFIG=${AWS_BEDROCK_CONFIG} \
    VITE_LOG_LEVEL=${VITE_LOG_LEVEL} \
    DEFAULT_NUM_CTX=${DEFAULT_NUM_CTX} \
    RUNNING_IN_DOCKER=true
# Pre-configure wrangler to disable metrics
RUN mkdir -p /root/.config/.wrangler && \
    echo '{"enabled":false}' > /root/.config/.wrangler/metrics.json
RUN pnpm run build
CMD ["pnpm", "run", "dockerstart"]
# Development image
FROM base AS bolt-ai-development
# Define the same environment variables for development
ARG GROQ_API_KEY
ARG HuggingFace_API_KEY
ARG OPENAI_API_KEY
ARG ANTHROPIC_API_KEY
ARG OPEN_ROUTER_API_KEY
ARG GOOGLE_GENERATIVE_AI_API_KEY
ARG OLLAMA_API_BASE_URL
ARG OPENAI_LIKE_API_BASE_URL
ARG DEEPSEEK_API_KEY
ARG OPENAI_LIKE_API_KEY
ARG TOGETHER_API_KEY
ARG TOGETHER_API_BASE_URL
ARG HYPERBOLIC_API_KEY
ARG HYPERBOLIC_API_BASE_URL
ARG MISTRAL_API_KEY
ARG COHERE_API_KEY
ARG LMSTUDIO_API_BASE_URL
ARG XAI_API_KEY
ARG PERPLEXITY_API_KEY
ARG AWS_BEDROCK_CONFIG
ARG VITE_LOG_LEVEL=debug
ARG DEFAULT_NUM_CTX
ENV GROQ_API_KEY=${GROQ_API_KEY} \
    HuggingFace_API_KEY=${HuggingFace_API_KEY} \
    OPENAI_API_KEY=${OPENAI_API_KEY} \
    ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY} \
    OPEN_ROUTER_API_KEY=${OPEN_ROUTER_API_KEY} \
    GOOGLE_GENERATIVE_AI_API_KEY=${GOOGLE_GENERATIVE_AI_API_KEY} \
    OLLAMA_API_BASE_URL=${OLLAMA_API_BASE_URL} \
    OPENAI_LIKE_API_BASE_URL=${OPENAI_LIKE_API_BASE_URL} \
    DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY} \
    OPENAI_LIKE_API_KEY=${OPENAI_LIKE_API_KEY} \
    TOGETHER_API_KEY=${TOGETHER_API_KEY} \
    TOGETHER_API_BASE_URL=${TOGETHER_API_BASE_URL} \
    HYPERBOLIC_API_KEY=${HYPERBOLIC_API_KEY} \
    HYPERBOLIC_API_BASE_URL=${HYPERBOLIC_API_BASE_URL} \
    MISTRAL_API_KEY=${MISTRAL_API_KEY} \
    COHERE_API_KEY=${COHERE_API_KEY} \
    LMSTUDIO_API_BASE_URL=${LMSTUDIO_API_BASE_URL} \
    XAI_API_KEY=${XAI_API_KEY} \
    PERPLEXITY_API_KEY=${PERPLEXITY_API_KEY} \
    AWS_BEDROCK_CONFIG=${AWS_BEDROCK_CONFIG} \
    VITE_LOG_LEVEL=${VITE_LOG_LEVEL} \
    DEFAULT_NUM_CTX=${DEFAULT_NUM_CTX} \
    RUNNING_IN_DOCKER=true
# *** ADDED NODE_MODULES LISTING HERE FOR DEVELOPMENT IMAGE TOO ***
RUN echo "--- Listing node_modules directory (Development Image) ---" && \
    ls -alh node_modules && \
    echo "--- Checking for @remix-run/dev in node_modules (Development Image) ---" && \
    ls -alh node_modules/@remix-run/dev && \
    echo "--- Checking for vite in node_modules (Development Image) ---" && \
    ls -alh node_modules/vite && \
    echo "--- End of node_modules listing (Development Image) ---"
RUN mkdir -p /app/run
CMD ["pnpm", "run", "dev", "--host"]
