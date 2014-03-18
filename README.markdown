# CIC Payment

CIC Payment is a plugin to ease credit card payment with the CIC / Credit Mutuel banks system version 3.0.
It's a Ruby on Rails port of the connexion kits published by the bank.

* The banks payment [site](http://www.cmcicpaiement.fr)


## INSTALL

In your Gemfile

    gem 'cic_payment'

## USAGE

### Setup

Create a `cic_payment.yml` config file in the `Rails.root/config` directory:

    base: &base
      # Hmac key calculated with the js calculator given by CIC
      hmac_key: "AA123456AAAAAA789123BBBBBB123456CCCCCC12345678"

      # TPE number
      tpe: "010203"

      # Version
      version: "3.0"

      # Merchant name
      societe: "marchantname"

      # Auto response URL
      url_retour: 'http://return.fr'

      # Success return path
      url_retour_ok: 'http://return.ok'

      # Error/cancel return path
      url_retour_err: 'http://return.err'

      target_url: "https://paiement.creditmutuel.fr/test/paiement.cgi"

    production:
      <<: *base
      target_url: "https://paiement.creditmutuel.fr/paiement.cgi"

    development:
      <<: *base

    test:
      <<: *base

***Note:*** this file _must_ be named _exactly_ `cic_payment.yml` or an exception would be raised

`target_url` needs to point to the controller method handling the bank response (e.g. see below `payments#create`)

### In the controller :

    class PaymentsController < ApplicationController

      def index
        # :montant and :reference are required, you can also add :texte_libre, :lgue and :mail arguements if needed
        @request = CicPayment.new.request(:montant => '123', :reference => '456')
      end

### Then in the view, generate the form:

  The form generated is populated with hidden fields that will be sent to the bank gateway

    # :button_text and :button_class are optionnal, use them for style cutomization if needed
    = cic_payment_form(@request, :button_text => 'Payer', :button_class => 'btn btn-pink')

### Now, listen to the bank transaction result:

  Just add a create action in your payment controller

    class PaymentsController < ApplicationController

      protect_from_forgery :except => [:create]

      def index
        # :montant and :reference are required, you can also add :texte_libre, :lgue and :mail arguements if needed
        @request = CicPayment.new.request(:montant => '123', :reference => '456')
      end

      def create
        @response = CicPayment.new.response(params)

        # Save and/or process the order as you need it (or not)
      end

      ...

  The @response variable contains all the regular rails params received from the bank, plus an extra :success boolean parameter.


## Contributors
* Novelys Team : original gem and cryptographic stuff
* Guillaume Barillot : refactoring and usage simplification
* Michael Brung : configuration file refactoring.

## Licence
released under the MIT license