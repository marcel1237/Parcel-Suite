.PHONY: validate query-smoke

validate:
	python3 tools/validate_knowledge.py

query-smoke:
	python3 tools/query_knowledge.py FreeBSD sys/kern
	python3 tools/query_knowledge.py Ubuntu Resolute Noble
	python3 tools/query_knowledge.py Jails namespaces Capsicum
