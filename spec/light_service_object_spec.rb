class MyService < LightServiceObject::Base
  required :name
  optional :date

  def perform
    true
  end
end

RSpec.describe LightServiceObject do
  it "has a version number" do
    expect(LightServiceObject::VERSION).not_to be nil
  end

  context "success /w required params" do
    class MyService < LightServiceObject::Base
      required :name

      def perform
        "hello"
      end
    end

    it "failure without optional param" do
      result = MyService.call()
      expect(result.success?).to eq(false)
      expect(result.failure).to eq("MyService: option 'name' is required")
    end
  end

  context "success /w optional params" do
    class MyService < LightServiceObject::Base
      required :name
      optional :date

      def perform
        "hello"
      end
    end

    it "success including optional param" do
      result = MyService.call(name: "test", date: "2019/09/26")
      expect(result.success?).to eq(true)
      expect(result.value!).to eq("hello")
    end

    it "success without optional param" do
      result = MyService.call(name: "test")
      expect(result.success?).to eq(true)
      expect(result.value!).to eq("hello")
    end
  end

  context "Mutable attributes" do
    it "mutable works" do
      class Mutable < LightServiceObject::Base
        required :name
        optional :date, mutable: true

        def perform
          self.date = "not_a_date"
          date
        end
      end

      result = Mutable.call(name: "test", date: "2019/09/26")

      expect(result.success?).to eq(true)
      expect(result.value!).to eq("not_a_date")
    end

    it "should be immutable by default" do
      class Immutable < LightServiceObject::Base
        required :name
        optional :date

        def perform
          self.date ||= "not_a_date"
          date
        end
      end

      result = Immutable.call(name: "test", date: "2019/09/26")

      expect(result.success?).to eq(true)
      expect(result.value!).to eq("2019/09/26")
    end
  end


  context "failures" do
    it "should fail if required param isn't given" do
      class FailClass < LightServiceObject::Base
        required :name
        optional :date

        def perform
          self.date ||= "not_a_date"
          date
        end
      end

      result = FailClass.call(date: "2019/10/10")
      expect(result.success?).to eq(false)
    end

    it "should return failure if fail!() called" do
      class FailClass < LightServiceObject::Base
        required :name
        optional :date

        def perform
          fail!("Always fails")
          self.date ||= "not_a_date"
          date
        end
      end

      result = FailClass.call(name: "Noname")
      expect(result.failure?).to eq(true)
    end
  end

end
