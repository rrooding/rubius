class String
  def xor(s2)
    if s2.empty?
      self
    else
      a1 = self.unpack("c*")
      a2 = s2.unpack("c*")
      
      a2 *= 2 while a2.length < a1.length
      
      a1.zip(a2).collect{|c1,c2| c1^c2}.pack("c*")
    end
  end
end
