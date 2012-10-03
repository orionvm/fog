module Fog
  module Compute
    class OrionVM
      class Real

        # Creates a new account.
        #
        # This is the equivelant of signing up through the V1 signup form.
        #
        # ==== Parameters
        # * username<~String> - A valid email address
        # * password<~String> - A new password to login with
        # * password2<~String> - Confirm new password
        # * title<~String> - A salutation for this user
        # * firstname<~String> - User first name
        # * lastname<~String> - User last name
        # * company<~String> - A valid company name
        # * address<~String> - Street address
        # * suburb<~String> - An Australian suburb
        # * country<~String> - 'au' only.
        # * state<~String> - State or Territory (Australia Only)
        # * postcode<~String> - Postcode
        # * mobile_phone<~String> - A mobile number
        # * home_phone<~String> - A home contact number
        # * ccnumber<~String> - Credit card number
        # * ccnameoncard<~String> - Name of card holder
        # * ccexpirymonth<~Integer> - e.g. 08
        # * ccexpiryyear<~Integer> - e.g. 13
        # * cvn<~Integer> - Card Verification Number
        # * code<~Integer> - Promo Code
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def create_user(username, password, title, full_name, company, address,
                       suburb, country, state, postcode, phone_mobile, phone_home,
                       credit_card_number, credit_card_name, credit_card_expiry_month,
                       credit_card_expiry_year, credit_card_verification_number,
                       promo_code = nil)

          first_name, last_name = full_name.split(' ', 2)

          body = {
            :username => username,
            :password => password,
            :password2 => password,
            :title => title,
            :firstname => first_name,
            :lastname => last_name,
            :company => company,
            :address => address,
            :suburb => suburb,
            :country => country,
            :state => state,
            :postcode => postcode,
            :mobile_phone => phone_mobile,
            :home_phone => phone_home,
            :ccnumber => credit_card_number,
            :ccnameoncard => credit_card_name,
            :ccexpirymonth => credit_card_expiry_month,
            :ccexpiryyear => credit_card_expiry_year,
            :cvn => credit_card_verification_number,
            :code => promo_code
          }
          post('create_user', body, {:response_type => :hash})
        end

        def create_test_user(username)
          create_user(username, 'letmein123', 'mr', 'Will Powers', 'Test Company',
                     '104 Bathurst Street', 'Sydney', 'au', 'NSW', '2000', '0432221631',
                     '0998765432', '4444333322221111', 'Will Powers', 8, 13, '123')
        end
      end

      class Mock
        def create_test_user(username)
          create_user(username, 'letmein123', 'mr', 'Will Powers', 'Test Company',
                     '104 Bathurst Street', 'Sydney', 'au', 'NSW', '2000', '0432221631',
                     '0998765432', '4444333322221111', 'Will Powers', 8, 13, '123')
        end

        def create_user(username, password, title, full_name, company, address,
                       suburb, country, state, postcode, phone_mobile, phone_home,
                       credit_card_number, credit_card_name, credit_card_expiry_month,
                       credit_card_expiry_year, credit_card_verification_number,
                       promo_code = nil)
          response = Excon::Response.new

          if username =~ /^connect|test/
            response.status = 200
            response.body = {"success"=>true, "error"=>"Success"}
          else
            response.status = 500
            response.body = {:error => "User already exists"}
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
          response
        end

      end

    end
  end
end

