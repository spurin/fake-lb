docker buildx create --name build_cross --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10000000 --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=10000000
docker buildx use build_cross
docker buildx build --platform linux/amd64,linux/arm64/v8,linux/arm/v6,linux/arm/v7 -t spurin/fake-lb:latest . --push
