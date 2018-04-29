#!/bin/ksh

#-------------------------------------------------------------------------------------------------------------------#
#                                                                                                                   #
# Script Name   : almon.sh.                                                                                         #
# Date of birth : 03/14/2015.                                                                                       #
# Author        : r2d2c3p0.                                                                                         #
# Explanation   : Tool to manage the alerts and monitoring generated by almon.py.                                   #
# Dependencies  : The almon directory with all the required files.                                                  #
# Modifications : 03/14/2015 - Original version ($1.0v$)                                                            #
# Version       : 1.0v                                                                                              #
# Contact       : r2d2c3p0                                                                        #
#                                                                                                                   #
#-------------------------------------------------------------------------------------------------------------------#

#-------------------------------------------------------------------------------------------------------------------#
# 0. Initialization and global variables.                                                                           #
#-------------------------------------------------------------------------------------------------------------------#

cfg_file=almon/config/almon.config

host_sender=`hostname`
got_start=0
got_ooo=0
got_ack=0
got_suspend=0
got_disable=0
got_enable=0
got_back=0
got_status=0
got_log=0
got_nlog=0

#-------------------------------------------------------------------------------------------------------------------#
# 0. Functions.                                                                                                     #
#-------------------------------------------------------------------------------------------------------------------#

function start_almon {
         ps -ef | grep almon.py | grep -v grep > /dev/null 2>&1
         if [[ $? -eq 1 ]]; then
            python ${temp_directory}/../py/startalmon.py
         else
            echo "|WARNING| Another instance of almon is running!"
            exit 30
         fi
}

function get_help {
         echo """

         almon.sh -argument <option>, where '-argument' can be any of the below values:

                  -disable = to disable almon tool.
                  -enable = to enable almon tool.
                  -status = prints the status of the tool: disabled or enabled.
                  -log = enable logging for debugging.
                  -nlog = disable logging.
                  -ooo <administrator name> = to place <administrator name> in out-of-office mode.
                  -back <administrator name> = to place <administrator name> back into alerting mode.
                  -ack <administrator name> = to acknowledge the connections alert, this will suspend the alerts for 5 minutes. 
                  -start = to start the almon tool.
                  -suspend <optional time in seconds> = to suspend the tool, if no time is given will suspend for 5 minutes.
                  -help = will print this message, usage information.

         "
         exit 0
}

function enable_disable {
         _key_=run.almon
         _action_=$1
         _value_=`grep ${_key_} ${cfg_file} | awk -F "=" '{print $2}'`
         if [[ ${_action_} == "disable" ]]; then
            if [[ ${_value_} -eq 0 ]]; then
               echo "almon is already disabled!"
               exit 1
            else
               key_line_number=`sed -n "/${_key_}/=" ${cfg_file}`
               perl -pi -e "s /1/0/ if $. == ${key_line_number}" ${cfg_file} > /dev/null 2>&1
               sleep 1
               echo "almon will be disabled."
            fi
         elif [[ ${_action_} == "enable" ]]; then
            if [[ ${_value_} -eq 1 ]]; then
               echo "almon is already enabled!"
               exit 1
            else
               key_line_number=`sed -n "/${_key_}/=" ${cfg_file}`
               perl -pi -e "s /0/1/ if $. == ${key_line_number}" ${cfg_file} > /dev/null 2>&1
               sleep 1
               echo "almon will be enabled."
               start_almon
            fi
         elif [[ ${_action_} == "status" ]]; then
            if [[ ${_value_} -eq 0 ]]; then
               echo "almon is disabled."
            elif [[ ${_value_} -eq 1 ]]; then
               echo "almon is enabled."
            fi
         elif [[ ${_action_} == "log" ]]; then
            ps -ef | grep almon.py | grep -v grep > /dev/null 2>&1
            if [[ $? -eq 0 ]]; then
               _key_=enable.logging
               _value_=`grep ${_key_} ${cfg_file} | awk -F "=" '{print $2}'`
               if [[ ${_value_} -eq 1 ]]; then
                  echo "logging is already enabled!"
                  exit 1
              else
                  key_line_number=`sed -n "/${_key_}/=" ${cfg_file}`
                  perl -pi -e "s /0/1/ if $. == ${key_line_number}" ${cfg_file} > /dev/null 2>&1
                  sleep 1
                  echo "almon logging will be enabled."
              fi
            else
              echo "|ERROR| almon is not running!"
              exit 9
            fi
         elif [[ ${_action_} == "nlog" ]]; then
            ps -ef | grep almon.py | grep -v grep > /dev/null 2>&1
            if [[ $? -eq 0 ]]; then
               _key_=enable.logging
               _value_=`grep ${_key_} ${cfg_file} | awk -F "=" '{print $2}'`
               if [[ ${_value_} -eq 0 ]]; then
                  echo "logging is already disabled!"
                  exit 1
              else
                  key_line_number=`sed -n "/${_key_}/=" ${cfg_file}`
                  perl -pi -e "s /1/0/ if $. == ${key_line_number}" ${cfg_file} > /dev/null 2>&1
                  sleep 1
                  echo "almon logging will be disabled."
              fi
            else
              echo "|ERROR| almon is not running!"
              exit 9
            fi
         fi
}

#-------------------------------------------------------------------------------------------------------------------#
# 1. Main.                                                                                                          #
#-------------------------------------------------------------------------------------------------------------------#

if [[ $# -ne 0 ]]; then
   while [[ $# -ne 0 ]]; do
         _arg_="$1"
         case ${_arg_} in
                       -disable)
                            got_disable=1
                            shift;
                            ;;
                       -enable)
                            got_enable=1
                            shift;
                            ;;
                       -start)
                            got_start=1
                            shift;
                            ;;
                       -nlog)
                            got_nlog=1
                            shift;
                            ;;
                       -ooo)
                            if [[ $# -lt 2 ]]; then
                               echo "|ERROR| administrator name is missing after '${_arg_}'."
                               echo "|INFO| Use '-h' or '-help' for usage information."
                               exit 1
                            fi
                            administrator_name="$2"
                            got_ooo=1
                            shift; shift
                            ;;
                       -back)
                            if [[ $# -lt 2 ]]; then
                               echo "|ERROR| administrator name is missing after '${_arg_}'."
                               echo "|INFO| Use '-h' or '-help' for usage information."
                               exit 1
                            fi
                            badministrator_name="$2"
                            got_back=1
                            shift; shift
                            ;;
                       -ack)
                            if [[ $# -lt 2 ]]; then
                               echo "|ERROR| administrator name is missing after '${_arg_}'."
                               echo "|INFO| Use '-h' or '-help' for usage information."
                               exit 1
                            fi
                            administrator_name_="$2"
                            got_ack=1
                            shift; shift
                            ;;
                       -suspend)
                            if [[ $# -lt 2 ]]; then
                               suspend_time=300
                            else 
                               suspend_time="$2"
                               shift;
                            fi
                            got_suspend=1
                            shift;
                            ;;
                       -h|-help)
                            get_help
                            ;;
                       -status)
                            got_status=1
                            shift;
                            ;;
                       -log)
                            got_log=1
                            shift;
                            ;;
                       *) 
                            echo "|ERROR| Input '${_arg_}' is not valid."
                            echo "|INFO| Use '-h' or '-help' for usage information."
                            exit 1 ;;
         esac
   done
else
   echo "|INFO| use '-h' or '-help' for usage."
   exit 0
fi

config_directory=`echo ${cfg_file} | awk -F '/' '{$(NF--)=""} BEGIN { OFS = "/"; ORS = "\n" }{ print }'`
[[ ! -d ${config_directory} ]] && { echo "|ERROR| ${config_directory} not found!" ; exit 1 ; }
temp_directory=`echo "${config_directory}../temp"`
suspension_file=`grep "suspend.file" ${cfg_file} | awk -F "=" '{print $2}'`
if [[ -z ${suspension_file} ]]; then
   echo "|ERROR| suspend.file's value is missing!"
   echo "|INFO| Check config file -> ${cfg_file}."
   exit 1
else
   [[ ! -d ${temp_directory} ]] && { echo "|ERROR| ${temp_directory} not found!" ; exit 1 ; }
fi

if [[ ${got_ooo} -eq 1 ]]; then
   a_name=`echo ${administrator_name} | awk '{print tolower($0)}'`
   if [[ -f ${config_directory}/${a_name}.email ]]; then
      echo "|INFO| placing ${a_name} in out-of-office mode."
      mv ${config_directory}/${a_name}.email ${config_directory}/ooo
   else
      echo "|ERROR| cannot place ${a_name} on OOO mode."
      exit 1
   fi
fi

if [[ ${got_ack} -eq 1 ]]; then
   [[ -f ${temp_directory}/${suspension_file} ]] && { echo "|WARNING| already acknowledged." ; exit 6 ; }
   a_name_=`echo ${administrator_name_} | awk '{print tolower($0)}'`
   if [[ -f ${config_directory}/${a_name_}.email ]]; then
      for emailfile in `ls ${config_directory}/*.email`; do
          email_address=`awk -F ',' 'BEGIN { OFS = ","; ORS = "\n" }{ print $1, $2 }' ${emailfile}`
          mail_group=`echo ${email_address},${mail_group}`
      done
      final_group=`print ${mail_group%?}`
      echo -e "Acknowledgement: ${administrator_name_}" | mail -r ${host_sender}.fb@efirstbank.com -s "Acknowledgement: ${administrator_name_}" ${final_group}
   else
      echo "|ERROR| action failed: ${a_name_}. Check if email files are avaliable."
      echo "|INFO| check if mail server is running and mail is configured."
      exit 1
   fi
   echo 300 > ${temp_directory}/${suspension_file}
fi

if [[ ${got_suspend} -eq 1 ]]; then
   [[ -f ${temp_directory}/${suspension_file} ]] && { echo "|WARNING| already suspended." ; exit 16 ; }
   ps -ef | grep almon.py | grep -v grep > /dev/null 2>&1
   if [[ $? -eq 0 ]]; then  
      echo ${suspend_time} > ${temp_directory}/${suspension_file}
      echo "|INFO| almon.py suspended for ${suspend_time} seconds."
   else
      echo "|ERROR| almon is not running, nothing to suspend."
      exit 5
   fi
fi

[[ ${got_start} -eq 1 ]] && start_almon
[[ ${got_disable} -eq 1 ]] && enable_disable "disable"
[[ ${got_enable} -eq 1 ]] && enable_disable "enable"
[[ ${got_status} -eq 1 ]] && enable_disable "status"
[[ ${got_log} -eq 1 ]] && enable_disable "log"
[[ ${got_nlog} -eq 1 ]] && enable_disable "nlog"

if [[ ${got_back} -eq 1 ]]; then
   ba_name=`echo ${badministrator_name} | awk '{print tolower($0)}'`
   if [[ -f ${config_directory}/ooo/${ba_name}.email ]]; then
      echo "|INFO| welcome back ${ba_name}, placing you back on alerting mode."
      mv ${config_directory}/ooo/${ba_name}.email ${config_directory}
   else
      echo "|ERROR| cannot place ${ba_name} on alerting mode."
      exit 1
   fi 
fi

#end_almon.sh