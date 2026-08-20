.PHONY: generate validate

generate:
	python3 generate_portal.py

validate: generate
	python3 ../supervised_learning/tools/validate_knowledge.py
	python3 validate_portal.py
