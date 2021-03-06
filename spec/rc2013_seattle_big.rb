require 'conf_helper'
require 'support/entities'

describe "Seattle Sample", :jruby => true do
  context Seattle do
    before(:all) do
      datomic_uri = "datomic:mem://seattle-#{SecureRandom.uuid}"
      @conn = Diametric::Persistence::Peer.connect(datomic_uri)
      Neighborhood.create_schema(@conn).get
      District.create_schema(@conn).get
      Seattle.create_schema(@conn).get
      filename = File.join(File.dirname(__FILE__), "data", "seattle-data0.dtm")
      list = Diametric::Persistence::Utils.read_all(filename)
      map = @conn.transact(list.first).get
    end

    after(:all) do
      @conn.release
    end

    it "should do queries" do
      query = Diametric::Query.new(Seattle, @conn)
      results = query.all    #362
      binding.pry

      query = Diametric::Query.new(Neighborhood, @conn).where(:name => "Capitol Hill")
      binding.pry
      # Navigating up 
      # 
      # 6 communities have their neighborhood whoose name is "Capitol
      # Hill"
      #
      seattles = query.first.seattle_from_this_neighborhood(@conn)
      binding.pry

      seattles.size.should == 6

      seattles.collect(&:name).should =~
        ["15th Ave Community",
         "Capitol Hill Community Council",
         "Capitol Hill Housing",
         "Capitol Hill Triangle",
         "CHS Capitol Hill Seattle Blog",
         "KOMO Communities - Captol Hill"]
      binding.pry

      #
      # Adds another set of data
      #
      # Makes sure "before" state
      #
      query = Diametric::Query.new(Seattle, @conn)
      results = query.all
      results.size.should == 362
      binding.pry

      past = Time.now

      binding.pry

      filename1 = File.join(File.dirname(__FILE__), "data", "seattle-data1.dtm")
      list = Diametric::Persistence::Utils.read_all(filename1)

      map2 = @conn.transact(list.first).get
      query = Diametric::Query.new(Seattle, @conn)
      results = query.all
      results.size.should == 571

      binding.pry

      past_db = @conn.db.as_of(past)

      binding.pry

      query = Diametric::Query.new(Seattle, past_db)
      results = query.all
      results.size.should == 362

      binding.pry
    end
  end
end
