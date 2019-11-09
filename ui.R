
# navbarPage(title="shinyGrades",

# tabPanel(
#   title = "Grade",
fluidPage(
  column(4,
         h2("Grade"),
         numericInput("grade_ws", "Worksheet number", 1, min = 1, max = num_ws),
         selectInput("grade_student", "Student Name", students),
         
         selectInput("grade_correctness", "Conceptual understanding -- Quality of answers explaining concepts", evaluation_levels, selected = "Did not turn in"),
         selectInput("grade_code", "Quality of code -- Are they able are to effectively use R to analyze data?", evaluation_levels, selected = "Did not turn in"),
         selectInput("grade_detail", "Effort -- Attention to detail/effort (thorough explanations, axes labels, using LaTeX)", evaluation_levels, selected = "Did not turn in"),
         checkboxInput("grade_TA_hours", "Attended TA hours"),
         
         helpText("ATTENTION: Do not use double or single quote in comments! You are recommended to write comments somewhere else and then copy to here; if the app crashes your writing will be lost."),
         textAreaInput("grade_general", "General Comments", height = '300px'),
         textInput("grade_time", "How long they spent on the homework"),
         selectInput("grade_enjoy", "How much they enjoyed it", enjoy_levels),
         selectInput("grade_helpful", "How much they found it helpful", helpful_levels),
         helpText("ATTENTION: Save for each student for each worksheet!"),
         actionButton("grade_save", "Save grades")
         
         
         # )
         
  ),
  # tabPanel(
  #   title ="See Grades",
  # fluidPage(
  column(8,
         h2("See grades"),
         helpText("Refresh grades if you don't see new grades. Refreshing never hurts"),
         actionButton("see_refresh", "Refresh grades"),
         
         selectInput("see_student", "Student Name", students)
         
         ,
         plotOutput("see_grades"),
         actionButton("see_pre_st", "Previous Student"),
         actionButton("see_next_st", "Next Student"),
         
         
         h2("Send grades"),
         helpText("Click through all the students before emailing out grades"),
         numericInput("email_ws", "Which worksheet was graded?", value = 1, max = num_ws),
         textInput("email_grader", "Who is grading?"),
         textInput("email_grader_email", "Email:"),
         textInput("email_grader_passowrd", "Password:"),
         actionButton("email_send", "Email grades")
         
  )  
)

# )



