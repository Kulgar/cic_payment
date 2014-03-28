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

      # New order, for instance
      def new
        @order = Order.build_from_basket(current_user.basket)
        order_info = { :user_id => current_user.id, :basket_id => current_user.basket.id }.to_json
        # :montant and :reference are required, you can also add :texte_libre, :lgue and :mail arguements if needed
        @request = CicPayment.new.request(:montant => @order.price, :reference => @order.unique_token, 
            :texte_libre => order_info)
      end

      # The action called by the 'return interface url' that you gave to the bank. 
      # Careful: It is not the same url as the ones you can configure in cic_payment.yml
      def create
        @response = CicPayment.new.response(params)
        
        # Save and/or process the order as you need it (or not).
        # Here is an example of what you can do: 
        if @response[:success]
            order_info = JSON.parse(@response["texte-libre"])
            basket = Basket.find(order_info["basket_id"].to_i)
            user   = User.find(order_info["user_id"].to_i)
            order = Order.build_from_basket(@response["reference"])
            if order.save
                OrderMailer.thanks(user.id, order.id).deliver
                basket.destroy # Or save it for statistics
            else
                logger.fatal "A fatal error occured for user #{user.id} while buying #{order.inspect}."
                logger.fatal order.errors.full_messages
                @response[:success] = false # Don't send back a success message.
            end
        end
        
        if Rails.env.production?
            # Sends back the expected message to the bank:
            if @response[:success] || @response["code-retour"].downcase == "annulation"
                render :text => "version=2\ncdr=0\n"
            else
                render :text => "version=2\ncdr=1\n"
            end
        else
            if @response[:success]
                flash[:notice] = "Thanks for your purchase. (Dev mode only)"
            else
                flash[:error] = "An error occured. (Dev mode only)"
            end
            redirect_to root_path
        end
      end

      ...

  The @response variable contains all the regular rails params received from the bank, plus an extra :success boolean parameter. Also the return code is already checked by the gem, the :success boolean will equal false for the "Annulation" (canceled) return code for instance. 

## TODO
* Handle multipart payments
* Better handle return codes so that we can do this: @response.cdr to retrieve correct cdr

## Contributors
* Novelys Team : original gem and cryptographic stuff
* Guillaume Barillot : refactoring and usage simplification
* Michael Brung : configuration file refactoring.
* Regis Millet (Kulgar) : refactoring and solved some bugs

## Licence
released under the MIT license
