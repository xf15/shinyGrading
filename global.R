library(readxl)
# library(ggthemes)
library(tidyverse)
library(reshape2)
# library(ggpubr)
# if(require(mailR)){
#   library(mailR)
#   # this is the even worse shiny one
#   # library(sendmailR)
# }

# one student whose last name is ward dropped the class and Josh Kingston joined the class after I made this.

rm(list=ls())
roster_info <- readxl::read_xls("roster_mock.xls")

# # will delete all grades careful!! should only be run at the beginning
bInitial = 0

evaluation_levels <- c("Excellent", "Good", "Fair", "Serious issues", "Did not turn in")
#evaluation_levels <- c("Excellent: almost everything correct", "Very good/good: most problems correct", "Fair: effort but a few significant mistakes", "Serious issues: many problems wrong/incomplete", "Did not turn in: in danger of not receiving an eval")
# # shiny doesn't take factor
# evaluation_levels <- factor(evaluation_levels, ordered = TRUE, levels = rev(evaluation_levels))

evaluation_list = 5:1
names(evaluation_list) = evaluation_levels

enjoy_levels <- c("Super fun", "kind of fun", "not really", "terrible")
enjoy_list=  4:1
names(enjoy_list) = enjoy_levels

helpful_levels <-c("learned a lot", "learned some", "learnt nothing", "so confused")
helpful_list = 4:1
names(helpful_list) = helpful_levels

numeric_metrics = c("correctness", "detail", "code")
metrics = c(numeric_metrics, "general_comment", "time", "TA_hours", "enjoy","helpful")
# a1 = as.data.frame(read_excel("grades.xlsx"))
students = roster_info$`Last Name`
first_names = roster_info$`First Name`
emails = roster_info$Email
num_ws = 5
grade_max = 8
email_suffix = "@hampshire.edu"


ws_dir = "worksheet_grades"
st_dir ="student_grades"

#' @export
#' create an empty dataframe for each worksheet, only run once at the beginning
create_initial_df_for_each_ws = function(my_students, my_metrics, my_num_ws){
  dir.create(ws_dir)
  dir.create(st_dir)
  df = data.frame(matrix(0L, nrow=length(my_students), ncol = length(my_metrics))*NA)
  # print(my_students)
  colnames(df) = my_metrics
  rownames(df) = my_students
  for(iWS in 1: my_num_ws){
  # for(iWS in 11:my_num_ws){
    eval(parse(text = paste0("ws", iWS, "= df")))
    filename = paste0(ws_dir, "/ws", iWS, ".rda")
    eval(parse(text = paste0("save(ws", iWS, ", file = filename)")))
    # save(df, file=paste0("ws", iWS, ".rda"))
  }
}


#' @export
#' run once when a new student joins in the class
add_students_to_graded_ws = function(new_student, my_metrics){
  for(iWS in 1:5){
    load(paste0(ws_dir, "/ws", iWS, ".rda"))
    eval(parse(text = paste0("df = ws", iWS)))
    df1 = data.frame(matrix(0L, 1,  ncol = length(my_metrics))*NA)
    colnames(df1) = my_metrics
    rownames(df1) = new_student
    df = rbind(df, df1)
    eval(parse(text = paste0("ws", iWS, "= df")))
    filename = paste0(ws_dir, "/ws", iWS, ".rda")
    eval(parse(text = paste0("save(ws", iWS, ", file = filename)")))
  }
}

#' @export
#' create an empty dataframe for each student at the begining, empty grades extracted from empty worksheet_grades. Called to update student_grades when chnanges are made to student_grades
create_df_for_each_student = function(my_students){
  print(students)
  for(iWS in 1: num_ws){
    load(paste0(ws_dir, "/ws", iWS, ".rda"))
  }
  for(iS in my_students){

    print(iS)
    eval(parse(text=paste0(iS, "= ws1['", iS, "',]")))
    for (iWS in 2:num_ws) {
      eval(parse(text = paste0(iS, "=rbind(", iS, ", ws", iWS, "['", iS, "',])")))
    }
    # eval(parse(text = paste0("rownames(", iS, ") = ")))
    filename = paste0(st_dir, "/", iS, ".rda")
    eval(parse(text = paste0("save(", iS, ", file = filename)")))
  }
}

if(bInitial==1){
  create_initial_df_for_each_ws(students, metrics, num_ws)
  create_df_for_each_student(students)
}


#C:\Program Files\Java\jdk1.8.0_161
email_grades = function(my_ws, my_grader){
  for(iS in 1:length(students)){
  # 11 is Josephine
  # for(iS in 11){
    load(paste0(st_dir, "/", students[iS], ".rda"))
    if (my_ws==1) {
      eval(parse(text = paste0("comment = ", students[iS], "['", students[iS], "', 'general_comment']")))
      eval(parse(text = paste0("correctness = ", students[iS], "['", students[iS], "', 'correctness']")))
      eval(parse(text = paste0("code = ", students[iS], "['", students[iS], "', 'code']")))
      eval(parse(text = paste0("detail = ", students[iS], "['", students[iS], "', 'detail']")))


    } else {
      eval(parse(text = paste0("comment = ", students[iS], "['", students[iS], my_ws-1, "', 'general_comment']")))
      eval(parse(text = paste0("correctness = ", students[iS], "['", students[iS], my_ws-1,"', 'correctness']")))
      eval(parse(text = paste0("code = ", students[iS], "['", students[iS], my_ws-1,"', 'code']")))
      eval(parse(text = paste0("detail = ", students[iS], "['", students[iS], my_ws-1,"', 'detail']")))
    }

    send.mail(from = paste0("cindyoutofoffice@gmail.com"),
              # to = paste0(acct[iS], email_suffix),
              to = emails[iS],
              subject = paste0("[stats for cognitive science] Your worksheet", my_ws, " is graded"),
              body = print(paste0("Hi ", first_names[iS], ",\n\nThis is your TA from Stats for Cognitive Psychology. Your worksheet", my_ws, " has been graded. Your got ", correctness, " for conceptual understanding, ", code, " for quality of code, and ", detail, " for attention to detail. Here is your narrative feedback:\n\n\n", comment, "\n\nEnjoy,\n",my_grader, "\n\nThis email is automated from R. Do not reply")),
              smtp = list(host.name="smtp.gmail.com", port=465, user.name="cindyisoutofoffice", passwd="12qw!@QW", ssl=TRUE),
              # attach.files = paste0(st_dir, "/", students[iS], ".rda"),
              file.names =  paste0(students[iS], ".rda"),
              authenticate = TRUE,
              send=TRUE,
              debug = TRUE)
    # attachmentPath = paste0(students[iS], ".rda")
    # attachmentName = attachmentPath
    # attachmentObject <- mime_part(x=attachmentPath,name=attachmentName)
    # bodyWithAttachment <- list(body,attachmentObject)
    # sendmail(from=from,to=to,subject=subject,msg=bodyWithAttachment,control=mailControl)
  }
}

# for (iS in 1: length(a1$X__1)){
#   b1 = excel_sheets("grades.xlsx")
#   eval(parse(text=paste0(a1$X__1[iS], "= a1[iS, -1]")))
#   for(iH in 1: length(b1)){
#     if(iH>1){
#       c1 = as.data.frame(read_excel("grades.xlsx", sheet = b1[iH]))
#       eval(parse(text=paste0(a1$X__1[iS], "= rbind(", a1$X__1[iS], ",c1[iS, -1])")))
#       eval(parse(text=paste0("rownames(", a1$X__1[iS], ") <- 1:nrow(", a1$X__1[iS], ")")))
#
#     }
#   }
# }
