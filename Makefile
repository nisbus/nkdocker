REPO ?= nkdocker
REBAR = rebar3
.PHONY: deps release

all: deps compile

compile:
	$(REBAR) compile

compile-nodeps:
	$(REBAR) compile skip_deps=true

deps:
	$(REBAR) get-deps

clean: 
	$(REBAR) clean

distclean: clean
	$(REBAR) delete-deps

tests: compile eunit

eunit:
	export ERL_FLAGS="-config test/app.config -args_file test/vm.args"; \
	$(REBAR) eunit skip_deps=true

shell:
	erl -config util/shell_app.config -args_file util/shell_vm.args -s nkdocker_app


docs:
	$(REBAR) skip_deps=true doc


APPS = kernel stdlib sasl erts ssl tools os_mon runtime_tools crypto inets \
	xmerl webtool snmp public_key mnesia eunit syntax_tools compiler
COMBO_PLT = $(HOME)/.$(REPO)_combo_dialyzer_plt

check_plt: 
	dialyzer --check_plt --plt $(COMBO_PLT) --apps $(APPS) deps/*/ebin

build_plt: 
	dialyzer --build_plt --output_plt $(COMBO_PLT) --apps $(APPS) deps/*/ebin

dialyzer:
	dialyzer -Wno_return --plt $(COMBO_PLT) ebin/nkdocker*.beam #| \
	    # fgrep -v -f ./dialyzer.ignore-warnings

cleanplt:
	@echo 
	@echo "Are you sure?  It takes about 1/2 hour to re-build."
	@echo Deleting $(COMBO_PLT) in 5 seconds.
	@echo 
	sleep 5
	rm $(COMBO_PLT)


build_tests:
	erlc -pa ebin -pa deps/lager/ebin -pa deps/nkpacket/ebin -o ebin -I include \
	+export_all +debug_info +"{parse_transform, lager_transform}" \
	test/*.erl
