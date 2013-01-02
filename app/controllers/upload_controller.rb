

class UploadController < ApplicationController


  def home
     render :file => 'app\views\upload\uploadfile.rhtml'
  
  end
 
  def create
  
    data = []
    units = []
    temps = [] # 2D array: ID, Name, Max Temp
    i = 0
    
    if params[:cts_file].blank?
      redirect_to :action => :home
      return
    end   
 
    f = params[:cts_file].tempfile
  
    while line = f.gets
      if line =~ /^Step/
        break    
      elsif line =~ /^Part/
        data = line.split(":",-1)          
        temps[i] = [data[1].slice(/\d+/),data[2].lstrip\
          .rstrip.sub(/Compact Thermal Model/,"CTM")]  
      elsif (line =~ /Maximum Temperature/ or line =~ /Junction Temp/)
        data = line.split("=",-1)
        temps[i][2] = data[1].lstrip.rstrip.slice(/\d+.\d{1,2}/)
        i+=1
        if units.empty?
          units = data[1].slice(/[A-Z]{1,1}/).to_s()
        end
        next    
      end
    end
    
    max_temp_id = 0
    for i in 1..temps.size-1
      if temps[i][2].to_f > temps[max_temp_id][2].to_f
        max_temp_id = i
      end 
    end
    session[:maxtemp] = temps[max_temp_id][2]
    session[:maxpart] = temps[max_temp_id][1]
    
    csv_file = "public\\" + params[:cts_file].original_filename.sub(/.cts/,".csv")
    
    puts "\n\n"
    puts csv_file
    
    CSV.open(csv_file, "w") do |csv|
      csv << ["CSV generated online at simspecs.com"]
      csv << ["ID", "Name", "Max or Junction Temp" + "(" + units + ")"]
      for i in 0..temps.size-1
        csv << temps[i]
      end
    end
      
    render :action => 'new'
    
  end
  
end
