require File.dirname(__FILE__) + '/spec_helper.rb'

JAPI::Story.class_eval do

  def self.collection_path
    "list/stories"
  end
  
end

describe JAPI::Client do
  
  describe 'api_request_url' do
    
    before do
      @client = JAPI::Client.new( :base_url => 'http://localhost:3000', :access_key => 'foo_key' )
    end
    
    it "should generate correct api url" do
      @client.api_request_url( 'success/path' ).should == "http://localhost:3000/api/foo_key/success/path"
      @client.api_request_url( 'error/path' ).should == "http://localhost:3000/api/foo_key/error/path"
    end
    
  end
  
  describe 'api_call' do
    
    before do
      @story_title = "Story Foo Title"
      @client = JAPI::Client.new( :base_url => 'http://localhost:3000', :access_key => 'foo_key' )
      @success_response_with_pagination = { :error => false, :message => 'api.call.success', :data => { :stories => [ JAPI::Story.new( :title => @story_title ) ], 
          :pagination => JAPI::Pagination.new( :total_pages => 1, :next_page => nil, :previous_page => nil ) } }.to_xml( :root => 'response' )
      @success_response_with_pagination_and_facets = { :error => false, :message => 'api.call.success', :data => { 
          :stories => [ JAPI::Story.new( :title => @story_title ) ], 
          :pagination => JAPI::Pagination.new( :total_pages => 1, :next_page => nil, :previous_page => nil ),
          :facets => JAPI::FacetCollection.new( [ JAPI::Facet.new( :filter => :is_blog, :value => true, :count => 10 ),
            JAPI::Facet.new( :filter => :is_video, :value => true, :count => 11 ),
            JAPI::Facet.new( :filter => :is_opinion, :value => true, :count => 12 )
             ] )
        } }.to_xml( :root => 'response' )
      @success_response_without_pagination = { :error => false, :message => 'api.call.success', :data => { :story => JAPI::Story.new(:title => @story_title ) } }.to_xml( :root => 'response')
      @error_response = { :error => true, :message => 'api.call.failure', :data => 'some failure cause' }.to_xml( :root => 'response' )
    end
    
    
    it "should make a successful api call without pagination" do
      @client.should_receive(:api_response).with('success_path', {}).and_return( @success_response_without_pagination )
      result = @client.api_call( 'success_path' )
      result[:error].should_not be_true
      result[:data].should be_is_a( JAPI::Story )
      result[:data].title.should ==( @story_title )
    end
    
    it "should make a successful api call with block and without pagination" do
      @client.should_receive(:api_response).with('success_path', {}).and_return( @success_response_without_pagination )
      proc = Proc.new do |data, pagination|
        data.should be_is_a( JAPI::Story )
        data.title.should ==( @story_title )
        pagination.should be_nil
      end
      proc.should_receive(:call)
      result = @client.api_call( 'success_path' ){ |data,pagination| proc.call( data, pagination ) }
      result[:error].should_not be_true
    end
    
    it "should make a successful api call with pagination" do
      @client.should_receive(:api_response).with('success_path', {}).and_return( @success_response_with_pagination )
      result = @client.api_call( 'success_path' )
      result[:error].should_not be_true
      result[:data].should be_is_a( Array )
      result[:data].each{ |s| s.should be_is_a( JAPI::Story ) }
      result[:data].collect( &:title ).should include( @story_title )
    end
    
    it "should make a successful api call with pagination and facets" do
      @client.should_receive(:api_response).with('success_path', {}).and_return( @success_response_with_pagination_and_facets )
      result = @client.api_call( 'success_path' )
      result[:error].should_not be_true
      result[:data].should be_is_a( Array )
      result[:data].each{ |s| s.should be_is_a( JAPI::Story ) }
      result[:data].collect( &:title ).should include( @story_title )
      result[:facets].should be_is_a( JAPI::FacetCollection )
      result[:facets].blog_count.should == 10
      result[:facets].video_count.should == 11
      result[:facets].opinion_count.should == 12
    end
    
    it "should make a successful api call with block and pagination" do
      @client.should_receive(:api_response).with('success_path', {}).and_return( @success_response_with_pagination )
      proc = Proc.new do | data, pagination |
        data.should be_is_a( Array )
        data.each{ |s| s.should be_is_a( JAPI::Story ) }
        data.collect( &:title ).should include( @story_title )
        pagination.should_not be_nil
        pagination.total_pages.should == 1
        pagination.next_page.should be_nil
        pagination.previous_page.should be_nil
      end
      proc.should_receive(:call)
      result = @client.api_call( 'success_path' ){ |data,pagination| proc.call( data, pagination ) }
      result[:error].should_not be_true
    end
    
    it "should return error false response on successful api" do
      @client.should_receive(:api_response).with('error_path', {}).and_return( @error_response )
      result = @client.api_call( 'error_path' )
      result[:error].should be_true
    end
    
    it "should not yield block on error" do
      @client.should_receive(:api_response).with('error_path', {}).and_return( @error_response )
      proc = Proc.new{ | data, pagination |  }
      proc.should_not_receive( :call )
      result = @client.api_call( 'error_path' ){ |data, pagination| proc.call( data, pagination ) }
      result[:error].should be_true
    end
    
    it "should be invoked using path chain" do
      @client.should_receive(:api_response).with('read/stories', {}).and_return( @success_response_without_pagination )
      result = @client.read.stories({})
      result[:error].should_not be_true
      result[:data].should be_is_a( JAPI::Story )
      result[:data].title.should ==( @story_title )
    end
  end
end

describe JAPI::Model::Base do
  
  describe 'class' do
    
    describe 'method new_factory' do
      
      it 'takes factory_type as first argument' do
        JAPI::Model::Base.new_factory( :story ).should be_a( JAPI::Story )
      end
      
      it 'takes attributes as second argument' do
        object = JAPI::Model::Base.new_factory( :story, { :title => 'Foo' })
        object.title.should == 'Foo'
      end
      
    end
    
    describe 'accessor attribute client' do
      
      it 'should provide attribute reader client' do
        JAPI::Model::Base.should be_respond_to( :client )
      end
      
      it 'should provide attribute writer client=' do
        JAPI::Model::Base.should be_respond_to( :client= )
      end
      
    end
    
    describe 'method exists?' do
      
      before do
        JAPI::Model::Base.client = JAPI::Client.new( :base_url => 'http://localhost:3000', :access_key => 'foo_key' )
        @element_response = { :error => false, :message => 'api.call.success', 
              :data => { :story => JAPI::Story.new( :title => 'Story 1', :id => 1 ) } }.to_xml( :root => 'response' )
        @record_not_found_response = { :error => true, :message => 'record.not.found', :data => '3' }.to_xml( :root => 'response')
      end
      
      it 'should return true if resource exists' do
        JAPI::Model::Base.client.should_receive(:api_response).with('read/stories', { :id => 1 }).and_return( @element_response  )
        JAPI::Story.should be_exists( 1 )
      end
      
      it 'should return false if resource does not exists' do
        JAPI::Model::Base.client.should_receive(:api_response).with('read/stories', { :id => 3 }).and_return( @record_not_found_response )
        JAPI::Story.should_not be_exists( 3 )
      end
      
    end
    
    describe 'method find' do
      
      def element_response( story )
        { :error => false, :message => 'api.call.success', 
            :data => { :story => story } }.to_xml( :root => 'response' )
      end
      
      before do
        @stories = (1..5).to_a.collect{ |x| JAPI::Story.new( :id => x, :title => "Story #{x}" ) }
        JAPI::Model::Base.client = JAPI::Client.new( :base_url => 'http://localhost:3000', :access_key => 'foo_key' )
        @record_not_found_response = { :error => true, :message => 'record.not.found', :data => '100' }.to_xml( :root => 'response')
        @collection_response = { :error => false, :message => 'api.call.success', 
            :data => { :stories => @stories, :pagination => JAPI::Pagination.new( :total_pages => 10, :next_page => 2, :previous_page => nil ) } }.to_xml( :root => 'response' )
      end
      
      it 'should return story by id' do
        @stories.each do |story|
          JAPI::Story.client.should_receive(:api_response).with('read/stories', { :id => story.id }).and_return( element_response( story ) )
          JAPI::Story.find( story.id ).should == story
        end
      end
      
      it 'should return nil if story does not exists' do
        JAPI::Story.client.should_receive(:api_response).with('read/stories', { :id => 100 }).and_return( @record_not_found_response )
        JAPI::Story.find( 100 ).should be_nil
      end
      
      it 'should return story by all' do
        JAPI::Story.client.should_receive(:api_response).with('list/stories', {}).and_return( @collection_response )
        result = JAPI::Story.find( :all )
        result.should == @stories
      end
      
      it 'should return story by first' do
        JAPI::Story.client.should_receive(:api_response).with('list/stories', {}).and_return( @collection_response )
        JAPI::Story.find(:first).should == @stories.first
      end
      
      it 'should return story by last' do
        JAPI::Story.client.should_receive(:api_response).with('list/stories', {}).and_return( @collection_response )
        JAPI::Story.find(:last).should == @stories.last
      end
      
      it 'should return story with from' do
        JAPI::Story.client.should_receive(:api_response).with('list/stories/advance', {}).and_return( @collection_response )
        result = JAPI::Story.find( :all, :from => :advance )
        result.should == @stories
      end
      
    end
    
    describe 'method create' do
      
      before do
        JAPI::Model::Base.client = JAPI::Client.new( :base_url => 'http://localhost:3000', :access_key => 'foo_key' )
        @create_success = { :error => false, :data => 1, :message => 'create.action.success' }.to_xml( :root => 'response' ) 
        @create_failure = { :error => true, :data => 'title can\'t be blank', :message => 'create.action.fail' }.to_xml( :root => 'response' )
      end
      
      it 'should create and instantiate a resource record on success' do
        JAPI::Story.client.should_receive( :api_response ).with('create/stories', { :story => {:title => 'Story 1'} }).and_return( @create_success )
        story = JAPI::Story.create( :title => 'Story 1' )
        story.should_not be_new
        story.title == 'Story 1'
        story.id == 1
      end
      
      it 'should not create but instantiate a resource record on failure' do
        JAPI::Story.client.should_receive( :api_response ).with('create/stories', { :story => {:title => ''} }).and_return( @create_failure )
        story = JAPI::Story.create( :title => '' )
        story.should be_new
        story.id.should be_nil
      end
      
    end
    
    describe 'method delete' do
      
      before do
        JAPI::Model::Base.client = JAPI::Client.new( :base_url => 'http://localhost:3000', :access_key => 'foo_key' )
        @delete_success = { :error => false, :data => 1, :message => 'delete.action.success' }.to_xml( :root => 'response' ) 
        @delete_failure = { :error => true, :data => ':id required', :message => 'delete.action.fail' }.to_xml( :root => 'response' )
      end
      
      it 'should return true on success' do
        JAPI::Story.client.should_receive( :api_response ).with('delete/stories', { :id => 1 } ).and_return( @delete_success )
        JAPI::Story.delete( 1 ).should be_true
      end
      
      it 'should return false on failure' do
        JAPI::Story.client.should_receive( :api_response ).with('delete/stories', { :id => nil } ).and_return( @delete_failure )
        JAPI::Story.delete( nil ).should be_false
      end
      
    end
    
  end
  
  describe 'instance' do
    
    describe 'method to_hash' do
      
      before do
        @record = JAPI::Story.new( :id => 1, :title => 'Story 1' , :authors => [ { :name => 'Author 1', :id => 1 }, { :name => 'Author 2', :id => 2 } ] )
        @hash = @record.to_hash
      end
      
      it 'should return story hash' do
        @hash.should be_key( :id )
        @hash.should be_key( :title )
      end
      
      it 'should not serialize nested ActiveResource Objects' do
        @hash.should_not be_key( :authors )
      end
    
    end
    
    describe 'method exists?' do
      
      before do
        JAPI::Model::Base.client = JAPI::Client.new( :base_url => 'http://localhost:3000', :access_key => 'foo_key' )
        @element_response = { :error => false, :message => 'api.call.success', 
              :data => { :story => JAPI::Story.new( :title => 'Story 1', :id => 1 ) } }.to_xml( :root => 'response' )
        @record_not_found_response = { :error => true, :message => 'record.not.found', :data => '3' }.to_xml( :root => 'response')
      end
      
      it 'should return true if resource exists' do
        JAPI::Story.client.should_receive( :api_response ).with('read/stories', { :id => '1' } ).and_return( @element_response )
        story = JAPI::Story.new( :id => 1, :title => 'Story 1' )
        story.exists?.should be_true
      end
      
      
      it 'should return false if resource does not exists' do
        JAPI::Story.client.should_receive( :api_response ).with('read/stories', { :id => '3' } ).and_return( @record_not_found_response )
        story = JAPI::Story.new( :id => 3, :title => 'Story 3' )
        story.exists?.should be_false
      end
      
    end
    
    describe 'method new_record?' do
      
      it 'should return false if resource has id' do
        story = JAPI::Story.new( :id => 1, :title => 'Story 1' )
        story.should_not be_new_record
      end
      
      
      it 'should return true if resource does not have id field set' do
        story = JAPI::Story.new( :title => 'Story 3' )
        story.should be_new_record
      end
      
    end
    
    describe 'method reload' do
      
      before do
        JAPI::Model::Base.client = JAPI::Client.new( :base_url => 'http://localhost:3000', :access_key => 'foo_key' )
        @story = JAPI::Story.new( :id => 1, :title => 'Story 1' )
        @element_response = { :error => false, :message => 'api.call.success', 
              :data => { :story => JAPI::Story.new( :title => 'New Story 1', :id => 1 ) } }.to_xml( :root => 'response' )
      end
      
      it 'should reload the resource' do
        JAPI::Story.client.should_receive( :api_response ).with('read/stories', { :id => '1' }).and_return( @element_response )
        @story.reload
        @story.title.should == 'New Story 1'
      end
      
    end
    
    describe 'method save on new record' do
      
      before do
        JAPI::Model::Base.client = JAPI::Client.new( :base_url => 'http://localhost:3000', :access_key => 'foo_key' )
        @create_success = { :error => false, :data => 1, :message => 'create.action.success' }.to_xml( :root => 'response' ) 
        @create_failure = { :error => true, :data => 'title can\'t be blank', :message => 'create.action.fail' }.to_xml( :root => 'response' )
        @story = JAPI::Story.new
      end
      
      
      it 'should create on succesful request' do
        JAPI::Story.client.should_receive( :api_response ).with('create/stories', { :story => { :title => 'Story 1' } } ).and_return( @create_success )
        @story.title = 'Story 1'
        @story.save.should be_true
      end
      
      it 'should not create on unsuccessful request' do
        JAPI::Story.client.should_receive( :api_response ).with('create/stories', { :story => {} } ).and_return( @create_failure )
        @story.save.should be_false
      end
      
      it 'should set id field after successful create' do 
        JAPI::Story.client.should_receive( :api_response ).with('create/stories', { :story => { :title => 'Story 1' } } ).and_return( @create_success )
        @story.title = 'Story 1'
        @story.save
        @story.id.should == 1
      end
      
      it 'should not set id field after unsuccessful request' do
        JAPI::Story.client.should_receive( :api_response ).with('create/stories', { :story => {} } ).and_return( @create_failure )
        @story.save
        @story.id.should be_nil
      end
      
    end
    
    
    describe 'method save on old record ' do
      
      before do
        JAPI::Model::Base.client = JAPI::Client.new( :base_url => 'http://localhost:3000', :access_key => 'foo_key' )
        @update_success = { :error => false, :data => 1, :message => 'update.action.success' }.to_xml( :root => 'response' ) 
        @update_failure = { :error => true, :data => 'title can\'t be blank', :message => 'update.action.fail' }.to_xml( :root => 'response' )
        @story = JAPI::Story.new( :id => 1, :title => 'Story 1' )
      end
      
      it 'should update on successful request' do
        JAPI::Story.client.should_receive( :api_response ).with('update/stories', { :story => { :id => 1, :title => 'Story 1' }, :id => '1' } ).and_return( @update_success )
        @story.save.should be_true
      end
      
      it 'should not update on unsuccessful request' do
        JAPI::Story.client.should_receive( :api_response ).with('update/stories', { :story => { :id => 1, :title => nil }, :id => '1' } ).and_return( @update_failure )
        @story.title = nil
        @story.save.should be_false
      end
      
      it 'should use prefix_options to reorder' do
        @story.prefix_options[:reorder] = 'up'
        JAPI::Story.client.should_receive( :api_response ).with('update/stories', { :story => { :id => 1, :title => 'Story 1' }, :id => '1', :reorder => 'up' } ).and_return( @update_success )
        @story.save.should be_true
      end
      
    end
    
    describe 'method destroy' do
      before do
        JAPI::Model::Base.client = JAPI::Client.new( :base_url => 'http://localhost:3000', :access_key => 'foo_key' )
        @delete_success = { :error => false, :data => 1, :message => 'delete.action.success' }.to_xml( :root => 'response' ) 
        @delete_failure = { :error => true, :data => ':id required', :message => 'delete.action.fail' }.to_xml( :root => 'response' )
        @story = JAPI::Story.new( :id => 1, :title => 'Story 1' )
      end
      
      
      it 'should return false if unsuccessful' do
        @story.id = nil
        JAPI::Story.client.should_receive( :api_response ).with('delete/stories', { :id => nil } ).and_return( @delete_failure )
        @story.destroy.should be_false
      end
      
      
      it 'should return true one success' do
        JAPI::Story.client.should_receive( :api_response ).with('delete/stories', { :id => '1' } ).and_return( @delete_success )
        @story.destroy.should be_true
      end
      
    end
    
  end
  
end

