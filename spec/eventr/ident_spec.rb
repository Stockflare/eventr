module Eventr

  class TestStaticIdent

    include Eventr::Identity

    property :favorite_animal

    ident :email

    def email
      @email ||= Faker::Internet.email
    end

    def favorite_animal
      "elephant"
    end

  end

  class TestProcIdent

    include Eventr::Identity

    property :favorite_color

    ident { email.upcase }

    def email
      @email ||= Faker::Internet.email
    end

    def favorite_color
      "red"
    end

  end

  describe TestStaticIdent do

    let(:test) { TestStaticIdent.new }

    subject { test }

    specify { expect(Eventr).to receive(:delegate_to_receivers).with(:identity, subject.email, subject.to_identity) }

    specify { expect_any_instance_of(Eventr::Receivers::Null).to receive(:identity).with(subject.email, subject.to_identity) }

    after { subject.send_identity }

  end

  describe TestProcIdent do

    let(:test) { TestProcIdent.new }

    subject { test }

    specify { expect(Eventr).to receive(:delegate_to_receivers).with(:identity, subject.email.upcase, subject.to_identity) }

    specify { expect_any_instance_of(Eventr::Receivers::Null).to receive(:identity).with(subject.email.upcase, subject.to_identity) }

    after { subject.send_identity }

  end

end
