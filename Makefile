2015 ::
	perl 2015.pl 1>dict-csld.json 2>index.json
	perl aux.pl

2013 ::
	perl 2013.pl 1>dict-csld.json 2>index.json

2014 ::
	perl 2014.pl 1>dict-csld.json 2>index.json

dev:
	cd api && poetry run uvicorn app:APP --reload --host 0.0.0.0

init:
	sudo chmod a+x scripts/*
	./scripts/init.sh