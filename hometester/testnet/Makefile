.PHONY: clean start stop build

CHANCOIND=chancoind
CHANCOINCLI=chancoin-cli
B1_FLAGS=-regtest
B2_FLAGS=-regtest
B1=-datadir=1 $(B1_FLAGS)
B2=-datadir=2 $(B2_FLAGS)
BLOCKS=1
ADDRESS=
AMOUNT=
ACCOUNT=
CHANCOIN_SRC_DIR=/home/tester/chancoin/src
DB4_LIB_DIR=/home/tester/chancoin/db4

MINER=cpuminer
MINER_FLAGS=-a cloverhash -D -P
MINER_URL_PREFIX="-o "

start:
	$(CHANCOIND) $(B1) -daemon
	$(CHANCOIND) $(B2) -daemon

generate:
	$(CHANCOINCLI) $(B1) generate $(BLOCKS)

getinfo:
	$(CHANCOINCLI) $(B1) getinfo
	$(CHANCOINCLI) $(B2) getinfo

send:
	$(CHANCOINCLI) $(B1) sendtoaddress $(ADDRESS) $(AMOUNT)

send2:
	$(CHANCOINCLI) $(B2) sendtoaddress $(ADDRESS) $(AMOUNT)

address:
	$(CHANCOINCLI) $(B1) getnewaddress $(ACCOUNT)

address2:
	$(CHANCOINCLI) $(B2) getnewaddress $(ACCOUNT)

stop:
	-$(CHANCOINCLI) $(B1) stop
	-$(CHANCOINCLI) $(B2) stop

mine1:
	$(MINER) $(MINER_FLAGS) $(MINER_URL_PREFIX)http://localhost:19001 -u admin1 -p 123 --coinbase-addr=$(ACCOUNT) $(EXTRA)

mine2:
	$(MINER) $(MINER_FLAGS) $(MINER_URL_PREFIX)http://localhost:19011 -u admin2 -p 123 --coinbase-addr=$(ACCOUNT) $(EXTRA)

build-chancoin:
	cd $(CHANCOIN_SRC_DIR)/.. && ./autogen.sh && ./configure LDFLAGS="-L$(DB4_LIB_DIR)/lib" CPPFLAGS="-I$(DB4_LIB_DIR)/include" && make
	echo "**** Tester's password is 'tester' ****"
	cd $(CHANCOIN_SRC_DIR)/.. && sudo make install

build: | stop build-chancoin clean start

clean:
	find 1/regtest/* -not -name 'server.*' -delete
	find 2/regtest/* -not -name 'server.*' -delete
