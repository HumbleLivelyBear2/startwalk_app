class PagesController < ApplicationController
  
  before_filter :session_url, :except => [:login]
  
  SITE_URL="http://localhost:3000/"
  
  
  def session_url
    session[:current_url] = request.url
  end
  def login
     # test = request.url
    #Rails.logger.info("XXXXXXXXXXXXXXXXXXXXXX     #{session[:current_url]}")
    @oauth = Koala::Facebook::OAuth.new("295205770520844", "a0aa290ff9019b2acb2250be19998936", session[:current_url])
    facebook_auth_url = @oauth.url_for_oauth_code
    redirect_to facebook_auth_url
  end
  
  
  # This action is usually accessed with the root path, normally '/'
  def home
    error_404 unless (@page = Page.where(:link_url => '/').first).present?
    
    call_back
    
    @test = @profile
    @test2 = @current_patner.nil?
    
    # Member.project; Project.hoster
    
    if !Project.all.empty?
     @projects = Project.all
    end
  end

  # This action can be accessed normally, or as nested pages.
  # Assuming a page named "mission" that is a child of "about",
  # you can access the pages with the following URLs:
  #
  #   GET /pages/about
  #   GET /about
  #
  #   GET /pages/mission
  #   GET /about/mission
  #
  def show

    call_back
    
    if params[:path] == "payments" # only for payments notification
      
       Payment.create!(:params => params, :cart_id => params[:invoice], :status => params[:payment_status], :transaction_id => params[:txn_id])
       render :nothing => true
      
    elsif  # find child page and redirect
      @page = Page.find("#{params[:path]}/#{params[:id]}".split('/').last)
      
      if @page.try(:live?) || (refinery_user? && current_user.authorized_plugins.include?("refinery_pages"))
        # if the admin wants this to be a "placeholder" page which goes to its first child, go to that instead.
        if @page.skip_to_first_child && (first_live_child = @page.children.order('lft ASC').live.first).present?
          redirect_to first_live_child.url and return
        elsif @page.link_url.present?
          redirect_to @page.link_url and return
        end
      else
        error_404
      end
    end
  
  end
  
  def call_back
    if params[:code].present?
      #Rails.logger.info"xxxxxxxxxxxxxxxx    #{session[:current_url][0..session[:current_url].index("?")-1]}"
      @oauth = Koala::Facebook::OAuth.new("295205770520844", "a0aa290ff9019b2acb2250be19998936", session[:current_url][0..session[:current_url].index("?")-1])
      access_token = @oauth.get_access_token(params[:code])
      @graph = Koala::Facebook::API.new(access_token)
      @profile = @graph.get_object("me")
      #Rails.logger.info("XXXXXXXXXXXXX: id XXXXXXXX: #{@profile.id}")
      @current_patner = find_or_create_member(@profile) # let current_partner combined with that member
      Rails.logger.info"xxxxxxxxxxxxxxxx it is current_partner   #{@current_patner}"
    end
  end
  
  def find_or_create_member(profile)
    if !Member.where("fb_id" => profile["id"]).empty?
      Rails.logger.info"xxxxxxxxxxxxxxxx    function Error!!!!!!!"
      Rails.logger.info"xxxxxxxxxxxxxxxx    #{profile["id"]}"
      member = Member.where("fb_id" => profile["id"])
      return member
      Rails.logger.info"xxxxxxxxxxxxxxxx    function Error2222222222!!!!!!!"
    else
      Rails.logger.info"oooooooooooooooo    function Good!!!!!!!"
      member = Member.new
      member.fb_id = profile["id"]
      member.member_name = profile["name"]
      member.save
      return member
    end
  end

end
