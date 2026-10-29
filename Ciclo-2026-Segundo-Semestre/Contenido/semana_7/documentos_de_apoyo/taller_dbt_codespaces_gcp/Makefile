.PHONY: setup validate debug seed run test docs workshop clean

setup:
	pip install -r requirements.txt
	bash scripts/setup_codespace.sh

validate:
	bash scripts/validate_environment.sh

debug:
	cd dbt && dbt debug

seed:
	cd dbt && dbt seed

run:
	cd dbt && dbt run

test:
	cd dbt && dbt test

docs:
	cd dbt && dbt docs generate && dbt docs serve --host 0.0.0.0 --port 8080

workshop:
	bash scripts/run_workshop.sh

clean:
	cd dbt && dbt clean

