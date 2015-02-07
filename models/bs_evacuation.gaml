/**
 *  bsevacuation
 *  Author: geonin
 *  Description: 
 */

model bsevacuation

global {
	/** Insert the global definitions, variables and actions here */
	file building_shp<-file("../includes/bs_buildings_utm.shp");

	geometry shape<-envelope(building_shp);		

	init{
		step <-1#mn;
		time<-6#h;
		create building from:building_shp; // with:[my_type::string(read("type"))];
	}
	
}

species building {
	string my_type;
	aspect geom {
	/*
		if(self.my_type='school'){
		draw shape color: #blue;}
		else{
			draw shape color: #red;}
		}
		 */
		 draw shape color: #red;
		 }
	}


experiment bsevacuation type: gui {
	/** Insert here the definition of the input and output of the model */
	output {

		display map type: opengl{
			species building aspect:geom refresh:false;
		}
		
	}
}
