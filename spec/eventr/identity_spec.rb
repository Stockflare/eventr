module Eventr

  class TestIdentity

    include Eventr::Identity

    property :$email, :mapped_email

    property :Favorite_Color, Proc.new { a_color.capitalize }

    def id
      1
    end

    def first_name
      "david"
    end

    def last_name
      "kelley"
    end

    def phone
      @phone ||= Faker::PhoneNumber.cell_phone
    end

    def mapped_email
      "hello@davidkelley.me"
    end

    def a_color
      "red"
    end

  end

  describe 'a properties class' do

    let(:test) { TestIdentity.new }

    subject { test }

    it { should respond_to(:to_identity) }

    it { should respond_to(:send_identity) }

    describe 'when #send_identity is called' do

      specify { expect(Eventr).to receive(:delegate_to_receivers).with(:identity, subject.id, subject.to_identity) }

      specify { expect_any_instance_of(Eventr::Receivers::Null).to receive(:identity).with(subject.id, subject.to_identity) }

      after { subject.send_identity }

    end

    describe 'return value of #to_identity' do

      subject { test.to_identity }

      it { should be_a Hash }

      specify { expect(subject.keys).to include '$first_name', '$last_name', '$email', '$phone', 'Favorite Color' }

      describe 'value of $first_name' do

        subject { test.to_identity['$first_name'] }

        it { should be_a String }

        it { should eq test.first_name }

      end

      describe 'value of $last_name' do

        subject { test.to_identity['$last_name'] }

        it { should be_a String }

        it { should eq test.last_name }

      end

      describe 'value of $phone' do

        subject { test.to_identity['$phone'] }

        it { should be_a String }

        it { should eq test.phone }

      end

      describe 'value of $email' do

        subject { test.to_identity['$email'] }

        it { should be_a String }

        it { should eq test.mapped_email }

      end

      describe 'value of Favorite Color' do

        subject { test.to_identity['Favorite Color'] }

        it { should be_a String }

        it { should eq test.a_color.capitalize }

      end

    end

  end

end
