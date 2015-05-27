module Eventr

  class TestEvents

    include Eventr::Track

    track :played_a_game

    track :"Threw_A_Ball", :ball_sizer

    track :sent_message, -> (contents) { { Message: contents } }

    # has_many :orders, after_add: :created_order!

    # track :created_order, -> (order) { { Items: order.items.count } }

    def id
      1
    end

    def ball_sizer(ball = nil)
      { Size: 1 }
    end

  end

  describe TestEvents do

    let(:test) { TestEvents.new }

    subject { test }

    it { should respond_to(:played_a_game!) }

    it { should respond_to(:threw_a_ball!) }

    it { should respond_to(:sent_message!) }

    describe 'when #played_a_game! is called' do

      let(:receiver) { Eventr::Receivers::Null.new }

      before { Eventr.stub(:receivers) { [receiver] } }

      specify { expect(receiver).to receive(:track).with(subject.id, 'Played A Game', anything()) }

      specify { expect { subject.played_a_game!({ Prop: true }) }.to_not raise_error }

      after { subject.played_a_game! }

    end

    describe 'when #threw_a_ball! is called' do

      let(:receiver) { Eventr::Receivers::Null.new }

      before { Eventr.stub(:receivers) { [receiver] } }

      specify { expect(receiver).to receive(:track).with(subject.id, 'Threw A Ball', hash_including(subject.ball_sizer)) }

      specify { expect { subject.threw_a_ball!({ Prop: true }) }.to_not raise_error }

      after { subject.threw_a_ball! }

    end

    describe 'when #sent_message! is called' do

      let(:receiver) { Eventr::Receivers::Null.new }

      let(:message) { Faker::Company.bs }

      before { Eventr.stub(:receivers) { [receiver] } }

      specify { expect(receiver).to receive(:track).with(subject.id, 'Sent Message', hash_including({ Message: message })) }

      specify { expect { subject.sent_message!('custom property') }.to_not raise_error }

      after { subject.sent_message!(message) }

    end

  end

end
