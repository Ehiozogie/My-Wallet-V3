proxyquire = require('proxyquireify')(require)

stubs = {
}

PaymentMethod    = proxyquire('../../src/coinify/payment-method', stubs)
o = undefined
coinify = undefined
b = undefined

beforeEach ->
  o = {
    inMedium: "inMedium"
    outMedium: "outMedium"
    name: "name"
    inCurrencies: "inCurrencies"
    outCurrencies: "outCurrencies"
    inCurrency: "inCurrency"
    outCurrency: "outCurrency"
    inFixedFee: 0.01
    outFixedFee: 0
    inPercentageFee: 3
    outPercentageFee: 0
  }
  JasminePromiseMatchers.install()

afterEach ->
  JasminePromiseMatchers.uninstall()

describe "Payment method", ->

  describe "constructor", ->
    it "must put everything on place", ->
      b = new PaymentMethod(o)
      expect(b._inMedium).toBe(o.inMedium)
      expect(b._outMedium).toBe(o.outMedium)
      expect(b._name).toBe(o.name)
      expect(b._inCurrencies).toBe(o.inCurrencies)
      expect(b._outCurrencies).toBe(o.outCurrencies)
      expect(b._inCurrency).toBe(o.inCurrency)
      expect(b._outCurrency).toBe(o.outCurrency)
      expect(b._inFixedFee).toBe(o.inFixedFee * 100)
      expect(b._outFixedFee).toBe(o.outFixedFee * 100)
      expect(b._inPercentageFee).toBe(o.inPercentageFee)
      expect(b._outPercentageFee).toBe(o.outPercentageFee)

    it "must correctly round the fixed fee for fiat to BTC", ->
      o.inFixedFee = 35.05 # 35.05 * 100 = 3504.9999999999995 in javascript
      o.outFixedFee = 35.05 # 35.05 * 100 = 3504.9999999999995 in javascript
      b = new PaymentMethod(o)
      expect(b.inFixedFee).toEqual(3505)
      expect(b.outFixedFee).toEqual(3505000000)

    it "must correctly round the fixed fee for BTC to fiat", ->
      o.inCurrency = "BTC"
      o.outCurrency = "EUR"
      o.inFixedFee = 35.05
      o.outFixedFee = 35.05
      b = new PaymentMethod(o)
      expect(b.inFixedFee).toEqual(3505000000)
      expect(b.outFixedFee).toEqual(3505)

  describe "fetch all", ->
    it "should authGET trades/payment-methods with the correct arguments", (done) ->
      coinify = {
        authGET: (method, params) -> Promise.resolve([o,o,o,o]),
      }
      spyOn(coinify, "authGET").and.callThrough()

      promise = PaymentMethod.fetchAll('EUR', 'BTC', coinify)
      argument = {
        inCurrency: 'EUR',
        outCurrency: 'BTC'
      }
      testCalls = () ->
        expect(coinify.authGET).toHaveBeenCalledWith('trades/payment-methods', argument)
      promise
        .then(testCalls)
        .then(done)

    describe "instance", ->
      it "should have getters", ->
        b = new PaymentMethod(o)
        expect(b.inMedium).toBe(o.inMedium)
        expect(b.outMedium).toBe(o.outMedium)
        expect(b.name).toBe(o.name)
        expect(b.inCurrencies).toBe(o.inCurrencies)
        expect(b.outCurrencies).toBe(o.outCurrencies)
        expect(b.inCurrency).toBe(o.inCurrency)
        expect(b.outCurrency).toBe(o.outCurrency)
        expect(b.inFixedFee).toBe(o.inFixedFee * 100)
        expect(b.outFixedFee).toBe(o.outFixedFee * 100)
        expect(b.inPercentageFee).toBe(o.inPercentageFee)
        expect(b.outPercentageFee).toBe(o.outPercentageFee)

      describe "calculateFee()", ->
        beforeEach ->
          b = new PaymentMethod(o)

        it "should set fee, given a quote", ->
          b.calculateFee({baseAmount: -1000})
          expect(b.fee).toEqual(30 + 1)

        it "should set total, given a quote", ->
          b.calculateFee({baseAmount: -1000})
          expect(b.total).toEqual(1000 + 30 + 1)
