#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
fieldsMandatory <- c("aadhar","name")
source("main.R")
#run1<-parse("main.R")
#eval(run1)
# Define server logic required to draw a histogram

shinyServer(
    function(input,output,session){
        
        observe({
            mandatoryFilled <-
                vapply(fieldsMandatory,
                       function(x) {
                           !is.null(input[[x]]) && input[[x]] != ""
                       },
                       logical(1))
            mandatoryFilled <- all(mandatoryFilled)
            
            shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
        })
        
        observeEvent(
            input$submit,{
                updateTabsetPanel(session, "inTabset", selected = "panel2")
            }
        )
        observeEvent(
            input$jumpToReport,{
                updateTabsetPanel(session, "inTabset", selected = "panel4")
            }
        )
        observeEvent(
            input$jumpToRecords,{
                updateTabsetPanel(session, "inTabset", selected = "panel3")
            }
        )
        result<-eventReactive(input$submit,
                              {
                                  
                                  ha<-matrix(ncol = 13,c(as.numeric(input$age),as.numeric(input$sex),as.numeric(input$cp),as.numeric(input$trestbps),as.numeric(input$chol),as.numeric(input$fbs),as.numeric(input$restecg),as.numeric(input$thalach),as.numeric(input$exang),as.numeric(input$oldpeak),as.numeric(input$slope),as.numeric(input$ca),as.numeric(input$thal)))
                                  colnames(ha)<-c("age","sex","cp","trestbps","chol","fbs","restecg","thalach","exang","oldpeak","slope","ca","thal")
                                  k<-as.data.frame(ha)
                                  #write.csv(k,"file.csv",row.names = FALSE)
                                  pred_system<-predict(model_gbm,k,method="class",type="prob")
                                  date <- format(Sys.Date(),"%d-%m-%y")
                                  day <- format(Sys.time(), "%A")
                                  time <- format(Sys.time(), "%X")
                                  pred_res <- data.frame("Date" = date, "Day" = day, "Time" = time, "Probability" = pred_system$positive)
                                  f <- paste(input$aadhar,".csv",sep = "")
                                  if(!file.exists(f))
                                      write.csv(pred_res,f,row.names = FALSE)
                                  else
                                  {
                                      df <- read.csv(f)
                                      df <- rbind(pred_res,df)
                                      write.csv(df,f,row.names = FALSE)
                                  }
                                  #output$plot<-hist(pred_result)
                                  #output$input_result<-renderTable({paste(pred_result)})
                                  #assign(res, pred_result$positive, envir = .GlobalEnv)
                                  pred_system$positive
                              })
        
        output$text <- renderText({paste("The probability of heart disease is ",result(),"")}) 
        # output$plot <- renderPlot({
        #     featurePlot(x=training[,c("age","cp","trestbps","chol","thalach","oldpeak")],
        #                 y=training$num,plot = "density",scales=list(x=list(relation="free"), y=list(relation="free")), auto.key=list(columns=2))
        #     
        #     
        # })
        
        mydata <- eventReactive(input$submit, {
            read.csv(paste(input$aadhar,".csv",sep = ""))
        })
        
        output$table <- renderTable(
            mydata()
        )
        
        output$report <- renderUI(
            {
            f <- paste(input$aadhar,".csv",sep = "")
            res <- read.csv(f)
            res <- res[[4]][[1]]
            print(res)
            ans <- paste("<b> Your probablity of heart of disease is </b>",res)
            name <- paste("<b>","Name: ","</b>",input$name)
            age <- paste("<b>","Age: ","</b>",input$age)
            sex <- paste("<b>","Gender: ","</b>")
            #------------------------------------------------
            line <- paste("<b>----------------------------------------------------------------------------------------------------------------------------------------------</b>")
            if(input$sex == 0)
                sex <- paste(sex,"Female")
            else
                sex <- paste(sex,"Male")
            bp <- paste("<b>","Resting Blood Pressure: ","</b>",as.character(input$trestbps),"mmHg")
            bp_info <- "BP is Normal"
            #FOR FASTING BLOOD SUGAR
            if(input$trestbps>=140){
                r <- nrow(BP)
                i <- upperBound(r,res)
                gen_name <- paste("<b>","Drug (Generic Name) :- ","</b>",BP[i,"generic"])
                com_name <- paste("<b>","Drug (Common Name) :- ","</b>",BP[i,"common"])
                use <- paste("<b>","Uses :- ","</b>",BP[i,"use"])
                side <- paste("<b>","Side Effects :- ","</b>",BP[i,"side_effect"])
                pre <- paste("<b>","Precautions :- ","</b>",BP[i,"precaution"])
                bp_info <- paste("BP should be controlled","<center><h4>Medication to follow</center></h4>",gen_name,com_name,use,side,pre,sep = "</br>")
            }
            #FOR SUGAR
            su <- paste("<b>","Fasting Blood Sugar is greater than 120mg/dl ","</b>")
            su_info <- "Fasting Blood Sugar is Normal"
            if(input$fbs==1){
                r <- nrow(sugar)
                i <- upperBound(r,res)
                gen_name <- paste("<b>","Drug (Generic Name) :- ","</b>",sugar[i,"generic"])
                com_name <- paste("<b>","Drug (Common Name) :- ","</b>",sugar[i,"common"])
                use <- paste("<b>","Uses :- ","</b>",sugar[i,"use"])
                side <- paste("<b>","Side Effects :- ","</b>",sugar[i,"side_effect"])
                pre <- paste("<b>","Precautions :- ","</b>",sugar[i,"precaution"])
                su_info <- paste("Blood Sugar should be controlled","<center><h4>Medication to follow</center></h4>",gen_name,com_name,use,side,pre,sep = "</br>")
            }
            #FOR CHOLESTEROL
            ch <- paste("<b>","Serum Cholesterol: ","</b>",as.character(input$trestbps),"mg/dl")
            ch_info <- "Serum Cholesterol is Normal"
            if(input$chol>=100){
                r <- nrow(chol)
                i <- upperBound(r,res)
                gen_name <- paste("<b>","Drug (Generic Name) :- ","</b>",chol[i,"generic"])
                com_name <- paste("<b>","Drug (Common Name) :- ","</b>",chol[i,"common"])
                use <- paste("<b>","Uses :- ","</b>",chol[i,"use"])
                side <- paste("<b>","Side Effects :- ","</b>",chol[i,"side_effect"])
                pre <- paste("<b>","Precautions :- ","</b>",chol[i,"precaution"])
                ch_info <- paste("Serum Cholesterol should be controlled","<center><h4>Medication to follow</center></h4>",gen_name,com_name,use,side,pre,sep = "</br>")
            }
            
            #CHEST PAIN
            cp <- paste("You have typical angina pain")
            cp_info <- ""
            if(input$cp == 1 && res>=0.80){
                r <- nrow(CP)
                i <- upperBound(r,res)
                gen_name <- paste("<b>","Drug (Generic Name) :- ","</b>",CP[1,"generic"])
                com_name <- paste("<b>","Drug (Common Name) :- ","</b>",CP[1,"common"])
                use <- paste("<b>","Uses :- ","</b>",CP[1,"use"])
                side <- paste("<b>","Side Effects :- ","</b>",CP[1,"side_effect"])
                pre <- paste("<b>","Precautions :- ","</b>",CP[1,"precaution"])
                cp_info <- paste("You have high chances of a heart disease","<center><h4>Medication to follow</center></h4>",gen_name,com_name,use,side,pre,sep = "</br>")
            }
            else if(input$cp == 1 && res<0.80){
                
                gen_name <- paste("<b>","Drug (Generic Name) :- ","</b>",CP[2,"generic"])
                com_name <- paste("<b>","Drug (Common Name) :- ","</b>",CP[2,"common"])
                use <- paste("<b>","Uses :- ","</b>",CP[2,"use"])
                side <- paste("<b>","Side Effects :- ","</b>",CP[2,"side_effect"])
                pre <- paste("<b>","Precautions :- ","</b>",CP[2,"precaution"])
                cp_info <- paste("You have low chances of a heart disease","<center><h4>Medication to follow</center></h4>",gen_name,com_name,use,side,pre,sep = "</br>")
            }
            else if(input$cp==2){
                
                gen_name <- paste("<b>","Drug (Generic Name) :- ","</b>",CP[3,"generic"])
                com_name <- paste("<b>","Drug (Common Name) :- ","</b>",CP[3,"common"])
                use <- paste("<b>","Uses :- ","</b>",CP[3,"use"])
                side <- paste("<b>","Side Effects :- ","</b>",CP[3,"side_effect"])
                pre <- paste("<b>","Precautions :- ","</b>",CP[3,"precaution"])
                cp_info <- paste("You have unstable Angina","<center><h4>Medication to follow</center></h4>",gen_name,com_name,use,side,pre,sep = "</br>")
                cp <- "You have unstable Angina pain"
            }
            else if(input$cp==3)
            {
                cp <- paste("You have Non-Angina pain")
                cp_info <- paste("<b>Non Angina pain can be treated with exercises.","Refer to excercises for more details.</b>")
            }
            else if(input$cp==4)
            { 
                gen_name <- paste("<b>","Drug (Generic Name) :- ","</b>",CP[3,"generic"])
                com_name <- paste("<b>","Drug (Common Name) :- ","</b>",CP[3,"common"])
                use <- paste("<b>","Uses :- ","</b>",CP[3,"use"])
                side <- paste("<b>","Side Effects :- ","</b>",CP[3,"side_effect"])
                pre <- paste("<b>","Precautions :- ","</b>",CP[3,"precaution"])
                cp_info <- paste("","<center><h4>Medication to follow</center></h4>",gen_name,com_name,use,side,pre,sep = "</br>")
                cp <- "Asymptotic Angina pain is the condition when there is a attack but pain is not felt."
            }
            extra <- ""
            if(res>0.90)
            { 
                gen_name <- paste("<b>","Drug (Generic Name) :- ","</b>",CP[3,"generic"])
                com_name <- paste("<b>","Drug (Common Name) :- ","</b>",CP[3,"common"])
                use <- paste("<b>","Uses :- ","</b>",CP[3,"use"])
                side <- paste("<b>","Side Effects :- ","</b>",CP[3,"side_effect"])
                pre <- paste("<b>","Precautions :- ","</b>",CP[3,"precaution"])
                extra <- paste("","<center><h4>Medication to follow</center></h4>",gen_name,com_name,use,side,pre,sep = "</br>")
            }
            #EXERCISES
            i <- input$age
            ex <- "<center><h3>EXERCISES TO FOLLOW</h3></center>"
            ex1 <- ""
            if(input$trestbps>=140)
                ex1 <- paste("<b>To control BP : </b>",bp_ex[i-29,"exercises"])
            ex2<-" "
            if(input$exang==1)
                ex2 <- paste("<b>If angina induces due to exercises, follow lighweight exercises like : </b>",exang_ex[i,"exercises"])
            ex3 <- ""
            if(input$fbs==1)
                ex3 <- paste("<b>To control Blood Sugar : </b>",fbs_ex[i-34,"exercises"])
            ex4 <- ""
            if(input$thalach>75)
                ex4 <- paste("<b>Heart rate shoud be nomalized</b>",heart_rate_ex[i+1,"exercises"])
            ex5 <- ""
            if(input$chol>=100)
                ex5 <- paste("<b>Serum Cholesterol should be controlled : </b>",chol_ex[i-34,"exercises"])
            ex <- paste(ex,"</br>",ex1,"</br>",ex2,"</br>",ex3,"</br>",ex4,"</br>",ex5)
            if(ex1=="" && ex2=="" && ex3=="" && ex4=="" && ex5=="")
                ex <- paste("You are free to do any kinds of exercises")
            HTML(paste(name,age,sex,ans,"</br>",line,bp,bp_info,line,su,su_info,line,ch,ch_info,line,cp,cp_info,extra,line,ex,line, sep = '<br/>'))
            
            }
        ) #End of report 
        
    }#End of function
)
