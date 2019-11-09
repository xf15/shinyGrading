function(input, output, session){
  
  
  rv = reactiveValues()
  rv$see_df = NULL
  rv$see_cur_st = NA
  
  
  
  observeEvent(input$grade_save,{
    
    
    eval(parse(text = paste0("load('", ws_dir,"/ws", input$grade_ws, ".rda')")))
    
    # # deprecated
    # Metrics_content = c(input$grade_correctness, input$grade_detail, input$grade_general)
    # eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "',]= Metrics_content")))
    for (iMetric in numeric_metrics) {
      eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','", iMetric, "']= as.numeric(evaluation_list['", input[[paste0('grade_', iMetric)]], "'])")))
    }
    
 
      eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','enjoy']= as.numeric(enjoy_list['", input[[paste0('grade_', 'enjoy')]], "'])")))
      eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','helpful']= as.numeric(helpful_list['", input[[paste0('grade_', 'helpful')]], "'])")))
    
    
    

 

    # eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','detail']=", as.numeric(input$grade_detail))))
    # eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','code']=", as.numeric(input$grade_code))))
    eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','time']=", as.numeric(input$grade_time))))
    eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','TA_hours']=", as.numeric(input$grade_TA_hours))))
    
    eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','general_comment']='", input$grade_general, "'")))
    print(as.numeric(input$grade_correctness))
    
    
    #eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','correctness']=", input$grade_correctness)))
    #eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','detail']=", input$grade_detail)))
    #eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','code']=", input$grade_code)))
    #eval(parse(text = paste0("ws", input$grade_ws, "['", input$grade_student, "','general comment']='", input$grade_general, "'")))
    
    
    
    
    
    print(paste0("ws", input$grade_ws, "['", input$grade_student, "',]= Metrics_content"))
    eval(parse(text= paste0("print(ws", input$grade_ws, ")"))) 
    filename = paste0(ws_dir, "/ws", input$grade_ws, ".rda")
    eval(parse(text = paste0("save(ws", input$grade_ws, ", file = filename)")))
    
  })
  
  
  
  observeEvent(input$see_refresh,{
    create_df_for_each_student(students)
    
  })
  
  
  
  observe({
    req(input$see_student)
    # req(input$see_refresh)
    filename = paste0(st_dir, "/", input$see_student, ".rda")
    eval(parse(text=paste0("load('", filename, "')")))
    eval(parse(text=paste0('rv$see_df = ', input$see_student)))
    rv$see_cur_st = match(input$see_student, students)
  })
  
  output$see_grades <- renderPlot({
    req(input$see_student)
    # req(input$see_refresh)
    df1 = rv$see_df
    # df1 = df1[numeric_Metrics]
    
    df1 = subset(df1, select=-c(general_comment))
    df1$ws = 1:nrow(df1)
    df2 = melt(df1, id='ws')
    print(df2)
    ggplot(df2, aes(ws, value, color=variable)) +
      geom_line(alpha=0.7) +
      # geom_point()+
      geom_point(size = 3, position = position_jitter(width=0.1, height=0.1)) +
      ylab("Grade") +
      xlab("Worksheet") +
      # 0 would occassionally disappear if ylim starts from 0 with jittering
      ylim(-1,grade_max) +
      # scale_y_discrete(limits=0:3) +
      scale_x_discrete(limits=1:nrow(df1))
    
    
  })
  
  observeEvent(input$see_next_st,{
    req(input$see_student)
    # req(input$see_refresh)
    if(rv$see_cur_st < length(students)){
      updateTextInput(session, "see_student", value = students[rv$see_cur_st + 1])
    }
  })
  
  observeEvent(input$see_pre_st,{
    req(input$see_student)
    # req(input$see_refresh)
    if(rv$see_cur_st > 1){
      updateTextInput(session, "see_student", value = students[rv$see_cur_st - 1])
    }
  })
  observeEvent(input$email_send,{
    req(input$email_ws)
    req(input$email_grader)
    email_grades(input$email_ws, input$email_grader)
  })
  
  
}