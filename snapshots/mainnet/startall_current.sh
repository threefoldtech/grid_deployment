#/bin/bash
docker start tfchain-main-pub-snapshot-current
docker start indexer_db_1
docker start indexer_redis_1
docker start indexer_indexer-status-service_1
docker start indexer_indexer-gateway_1
docker start indexer_indexer_1
docker start tfchain_graphql_db_1
docker start tfchain_graphql_query-node_1
docker start tfchain_graphql_processor_1
