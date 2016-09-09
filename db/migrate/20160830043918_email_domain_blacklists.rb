class EmailDomainBlacklists < ActiveRecord::Migration
	def change
		create_table :email_domain_blacklists, id: false do |t|
			t.primary_key :domain, :string, limit: 100
		end
	end
end
