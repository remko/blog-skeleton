require 'digest/sha1'

module FingerprintHelper
	def fingerprint(filename)
		Digest::SHA1.hexdigest(File.read(filename))[0..9]
	end
end
