/**
 *  urbanmobility
 *  Author: Group1
 *  Description: 
 */

model urbanmobility

global {
	int nb_happy_people<-0 update: people count(each.target=nil);
	int nb_people<-100;
	file road_hcr_shp <-file("../includes/bs_roads.shp");
	file building_hcr_shp<-file("../includes/bs_buildings.shp");
	file ec_shp <- file("../includes/bs_ec.shp");
	
	geometry shape<-envelope(building_hcr_shp);
	graph road_network;
	
	action blockroad (point lot, list<road> selected_agents) {
	
		road one_selected_agent<-nil;
		
		loop one_selected_agent over: selected_agents {
			one_selected_agent.passable <- false;
		}
		road_network <-as_edge_graph(road where (each.passable=true));
		}
		
	init{
		step <-1#mn;
		time<-6#h;
		//create road from:road_hcr_shp with:[my_speed::int(read("speed"))];
		create road from:road_hcr_shp with:[line_id::(read('line_id'))];
		create building from:building_hcr_shp with:[my_type::string(read("type"))];
		create ec from:ec_shp;
		create people number:nb_people{
			
			//work_place<-one_of(building where (each.my_type!='yes'));
			work_place<-one_of(ec);			
			
			house<-one_of(building where (each.my_type='yes'));
			
			my_road <- one_of(road);
			my_road.nb_drivers <- my_road.nb_drivers + 1;
			
			do create_static_timetable;
			//do create_variable_timetable;
	
			location <- house.location;
	}
	road_network <-as_edge_graph(road where (each.passable=true));
	}
	
	
}

species people skills:[moving]{
	rgb color<-rnd_color(255);
	building work_place;
	//float speed<-1#km/#h;
	building house;
	road my_road;
	bool is_arrived<-false;
	float transpo_duration<-0.0;
	activity target<-nil;
	//float speed<-my_road.current_speed;
	//float speed<-5 #km/#h update: (my_road!=nil ?5#km/#h*my_road.capacity/my_road.nb_drivers:0) min:0.5#km/#h max: 5.0#km/#h;
	//float speed<-5 #km/#h update: (my_road!=nil ?5#km/#h*my_road.capacity/my_road.nb_drivers:0) min:0.5#km/#h max: 5.0#km/#h;
	species activity{
		float start_time;
		building destination;
		
	}
	list<activity>my_activities<-nil;
		
	
	aspect people_disp{
		draw circle(10) color:#yellow;
		//draw sphere(12)at:{location.x,location.y,5}color:#yellow;
	} 
	
	point ilocation<-self.location;
	//int my_time<-my_activities
	reflex change_activity when: target=nil and !empty(my_activities){
		target<-first(my_activities);
		remove target from:my_activities;

	}
	
	float temp_transpo<-(-1.0);
	reflex moving when: target!=nil and target.start_time<=time{
		write "cooocoo";
		if(temp_transpo=-1){
			temp_transpo<-time;
		}
		do goto target:target.destination.location on:road_network;
		if(location distance_to target.destination.location<1#m){
			target<-nil;
			transpo_duration<-transpo_duration+(time-temp_transpo);
			write "fooo";
			temp_transpo<-(-1.0);
		}	
		if(my_road!=nil)
		{
			my_road.nb_drivers <- my_road.nb_drivers - 1;
		}
		
		my_road <- (road at_distance 10#m) closest_to self;
		
		if(my_road!=nil)
		{
			my_road.nb_drivers <- my_road.nb_drivers + 1;
		}
		
		}
		//reflex changed_target when:target!=nil and location distance_to target<1 {
		// target<-first(my_activities);
		//remove target from:my_activities;
	//}
	action create_static_timetable{
		create activity number:1 returns:first_activity{
				start_time<-8#h;
				destination<-work_place;
			}
	
			create activity number:1 returns:second_activity{
				start_time<-16#h;
				destination<-one_of(building where ((each!=work_place) and (each.my_type!='yes')));
			}
		
			create activity number:1 returns:third_activity{
				start_time<-18#h;
				destination<-house;
			}
			
			my_activities<-[first(first_activity),first(second_activity),first(third_activity)];
	}
	
	action create_variable_timetable{
		create activity number:1 returns:first_activity{
				start_time<-gauss(8#h,1#h);
				destination<-work_place;
			}
	
			create activity number:1 returns:second_activity{
				start_time<-gauss(15#h,1#h);
				destination<-one_of(building where ((each!=work_place) and (each.my_type!='yes')));
			}
		
			create activity number:1 returns:third_activity{
				start_time<-gauss(19#h,1#h);
				destination<-house;
			}
			
			my_activities<-[first(first_activity),first(second_activity),first(third_activity)];
	}
		
	
}

species ec {
	aspect geom {
		draw circle(15) color:#red;
	}	
} 

species road{
	int capacity <- 1 + int(shape.perimeter / 100.0) ;
	int nb_drivers <- 0;
	float speed_limit<-50#km/#h;
	bool passable<-true;
	int counter<-0;
	float current_speed<-speed_limit update: nb_drivers=0?0:speed_limit*exp(capacity/nb_drivers);
		aspect road_blocked {
		draw shape color: passable ? #green : #red;
		
	}
	aspect geom {

		//draw shape color: nb_drivers >  capacity ? #red : (nb_drivers > capacity/2 ? #orange : #black)depth: nb_drivers ;
		draw shape color: #blue;
	}
	
}

species building{
	string my_type;
	aspect geom {
		if(self.my_type='school'){
		draw shape color: #blue;}
		else{
			draw shape color: #red;}
		}
		
	}

experiment urbanmobility type: gui {
	output {
		//monitor "nb of happy people" value: nb_happy_people;
		display map type: opengl{
			species road aspect:geom;
			species building aspect:geom refresh:false;
			species people aspect: people_disp;
			species ec aspect:geom;
			
	}
	
		display blocked_map type: opengl{
		
			
			species road aspect:road_blocked;
			
			event mouse_down action: blockroad  ;
		}
		
		
	display average_time_duration {
			chart "Avarage transportation Duration" type:series{
				data "Transportation Duration" value: mean (people collect (each.transpo_duration));
			}
		
		}
		
	display average_speed {
			chart "Average Speed" type:series{
				data "Speed" value: mean (road collect (each.current_speed));
			}
		
		}
	}
	
	


}
