#voms-proxy-init --voms cms --valid 100:00

# do we submit or just generate submit scripts
dosubmit=false
doAOD=true
dominiAOD=false
domakeMiniAOD=false

# start the timer
START=$(date +%s);
printf "Started at ${START}\n\n"

if [ ${dominiAOD} = true ]
then
 nversion="${nversion}MiniAOD"
elif [ ${domakeMiniAOD} = true ]
then
 nversion="${nversion}MakeMiniAOD"
fi

printf "nversion is ${nversion} \n"
printf "configured as \n"
printf " doAOD=${doAOD}, dominiAOD=${dominiAOD}, domakeMiniAOD=${domakeMiniAOD}\n"

# make the directory where we'll submit from
thesubdir="${subdir}/gitignore/${nversion}"
mkdir -p ${thesubdir} 
printf "Making submit configurations in\n ${thesubdir}\n\n"

# copy necessary files into submit directory
if [ ${doAOD} = true ]
then
 dsubmitconfig="run_data_102XAOD.py"
 msubmitconfig="run_mc_102XAOD.py"
 thedasmap="${listdir}/ntuple/dasmapAOD.list"
# recycled file leaving this section for now but can delete later, only do AOD currently
elif [ ${dominiAOD} = true ]
then
 dsubmitconfig="run_data_102X.py"
 msubmitconfig="run_mc_102X.py"
 thedasmap="${listdir}/ntuple/dasmap.list"
elif [ ${domakeMiniAOD} = true ]
then
 dsubmitconfig="EXO-RunIISummer16MiniAODv2-DATA_cfg.py"
 msubmitconfig="EXO-RunIISummer16MiniAODv2-MC_cfg.py"
 thedasmap="${listdir}/ntuple/dasmapAOD.list"
else
 printf "SOMETHING'S UP --- YOU HAVE doAOD=${doAOD}, dominiAOD=${dominiAOD}, domakeMiniAOD=${domakeMiniAOD}\n"
fi

# copy cmsRun configuration to submit directory
cp "${subdir}/${dsubmitconfig}"  ${thesubdir}
cp "${subdir}/${msubmitconfig}"  ${thesubdir}


# sample names to run over
samples=( \
# put your samples here, copy from below
#"Data_EGamma_A"      \  
"Data_EGamma_B"      \ 
"Data_EGamma_C"      \  
#"Data_EGamma_D"      \  
#"DY50_1"    \
#"STs"    \             
#"STtbarW"    \             
)
#data

#"Data_DoubleMuon_A"      \
#"Data_DoubleMuon_B"      \
#"Data_DoubleMuon_C"      \
#"Data_DoubleMuon_D"      \
#"Data_EGamma_A"      \  
#"Data_EGamma_B"      \ 
#"Data_EGamma_C"      \  
#"Data_EGamma_D"      \  
#"Data_MuonEG_A"      \    
#"Data_MuonEG_B"      \    
#"Data_MuonEG_C"      \    
#"Data_MuonEG_D"      \    
                   
#BKG
#"QCD_HT50to100"      \                   
#"QCD_HT100to200"      \   
#"QCD_HT200to300"      \   
#"QCD_HT300to500"      \   
#"QCD_HT500to700"      \   
#"QCD_HT700to1000"      \  
#"QCD_HT1000to1500"      \ 
#"QCD_HT1500to2000"      \ 
#"QCD_HT2000toInf"      \  
                                  
#"GJets_HT40To100"\ 
#"GJets_HT100To200"\
#"GJets_HT200To400"\
#"GJets_HT400To600"\
#"GJets_HT600ToInf"\
                   
#"DY50_1_MG"      \
#"DY50_1"      \
#"DY_0J"      \
#"DY_1J"      \
#"DY_2J"      \
#"DY10to50"      \
#"DY5to50"      \
  
#"TTJets_MG"      \
#"TTJets"      \
#"TTtoLL_MG"      \
#"TTtoLL"      \
#"TTtoLfromT"      \
#"TTtoLfromTbar"      \

#"STs_3"      \             
#"STs"      \             
#"STt"      \             
#"STtbar"      \             
#"STtW_2"      \             
#"STtW"       \    
#"STtW_inc"      \ 
#"STtbarW_2"      \             
#"STtbarW"      \    
#"STtbarW_inc"      \             

#"WJets"      \     
                                    
#"WW"      \              
#"WZ"      \              
#"ZZ"      \                                                 
#"ZG"      \        
#"WG"      \        

#"WWToLNuQQ"      \
#"WWTo4Q"      \
#"WWTo2L2Nu"      \
#"WWTo1L1Nu2Q"      \
#"WZTo3LNu_1"      \
#"WZTo3LNu_powheg"      \
#"WZTo3LNu"      \
#"WZTo2L2Q"      \
#"ZZTo4L"      \
#"ZZTo4L_2"      \
#"ZZTo2Q2Nu"      \
#"ZZTo2L2Q"      \
#"ZZTo2L2Nu"      \
#"ZZTo2L2Nu_2"      \

              
#"ZH_Hbb_1"      \  
#"ZH_Hbb"      \        
#"ggZH_HToBB_ZToLL"\

#Signal

# print which samples we're running over
printf "For:\n"
for samplename in ${samples[@]} 
do
 printf " ${samplename}\n"
done

# loop over mc samples
for samplename in ${samples[@]}
do
 printf "\n******************************************************\n"
 if [ ${dosubmit} = true ]
 then
  printf "** \n"
  printf "** --- SUBMITTING --- \n"
  printf "** \n"
 fi
 printf "** Sample: ${samplename} \n"
 printf "******************************************************\n"
 printf "******************************************************\n\n"

 datasetname="$(grep -P ${samplename} ${thedasmap} | sed -n -e "s@ ${samplename}    @@p")"

 submitname="submit_${samplename}"
 submitfile="${thesubdir}/${submitname}.py"

 # set variables for submitting this specific sample
 WORKAREA="'crabsubmits_${nversion}'"

 # check if running data or MC
 if [[ "${samplename:0:4}" == "Data" ]]
 then
  dodata=true
 else
  dodata=false
 fi
 printf "dodata = ${dodata}\n"

 ## lumi mask
 LUMIMASK=""
 if [ ${dodata} = true ]
 then
     LUMIMASK="'${PWD}/jsons/Cert_314472-325175_13TeV_PromptReco_Collisions18_JSON.txt'"
 fi

 # choose correct config parameters
 if [ ${dodata} = true ]
 then 
  if [ ${doAOD} = true ]
  then
   # DATA AOD
   CMSRUNCONFIG="'${dsubmitconfig}'" 
   UPERJOB="50" #use when not automatic splitting
   #UPERJOB="180"
  elif [ ${dominiAOD} = true ]
  then
   # DATA miniAOD
   CMSRUNCONFIG="'${dsubmitconfig}'" 
   UPERJOB="100"
  elif [ ${domakeMiniAOD} = true ]
  then
   # DATA makeMiniAOD
   CMSRUNCONFIG="'${dsubmitconfig}'" 
   UPERJOB="100"
  fi
  SPLITTING="'LumiBased'"
  #SPLITTING="'Automatic'"
 else #if [ ${dodata} = true ]
  if [ ${doAOD} = true ]
  then
   # MC AOD
   CMSRUNCONFIG="'${msubmitconfig}'" 
   UPERJOB="180"
  elif [ ${dominiAOD} = true ]
  then
   # MC miniAOD
   CMSRUNCONFIG="'${msubmitconfig}'" 
   UPERJOB="1"
  elif [ ${domakeMiniAOD} = true ]
  then
   # MC makeMiniAOD
   CMSRUNCONFIG="'${msubmitconfig}'" 
   UPERJOB="1"
  fi
  #SPLITTING="'FileBased'"
  SPLITTING="'Automatic'"
 fi

 NUNITS="-1"
 REQUESTNAME="'${samplename}'"
 DATASET="'${datasetname}'"
 STORESITE="'T3_US_FNALLPC'"
 OUTLFNBASE="'/store/group/lpchbb/LLDJntuples/${nversion}'"
 MAXMEM="3000"
 #MAXMEM="4000"
 #MAXTM="1315"

 printf "WORKAREA      ${WORKAREA}     \n" 
 printf "CMSRUNCONFIG  ${CMSRUNCONFIG} \n" 
 printf "NUNITS        ${NUNITS}       \n" 
 printf "UPERJOB       ${UPERJOB}      \n" 
 printf "SPLITTING     ${SPLITTING}    \n" 
 printf "REQUESTNAME   ${REQUESTNAME}  \n" 
 printf "DATASET       ${DATASET}      \n" 
 printf "LUMIMASK      ${LUMIMASK}     \n" 
 printf "STORESITE     ${STORESITE}    \n" 
 printf "OUTLFNBASE    ${OUTLFNBASE}   \n" 
 printf "MAXMEM        ${MAXMEM}       \n" 

 # copy and then fill template for crab submits
 cp ${subdir}/crab_template.py             "${submitfile}"
 sed -i "s@WORKAREA@${WORKAREA}@g"         "${submitfile}"
 sed -i "s@CMSRUNCONFIG@${CMSRUNCONFIG}@g" "${submitfile}" 
 sed -i "s@NUNITS@${NUNITS}@g"             "${submitfile}" 
 sed -i "s@UPERJOB@${UPERJOB}@g"           "${submitfile}" 
 sed -i "s@SPLITTING@${SPLITTING}@g"       "${submitfile}" 
 sed -i "s@REQUESTNAME@${REQUESTNAME}@g"   "${submitfile}" 
 sed -i "s@DATASET@${DATASET}@g"           "${submitfile}" 
 sed -i "s@LUMIMASK@${LUMIMASK}@g"         "${submitfile}" 
 sed -i "s@STORESITE@${STORESITE}@g"       "${submitfile}" 
 sed -i "s@OUTLFNBASE@${OUTLFNBASE}@g"     "${submitfile}" 
 sed -i "s@MAXMEM@${MAXMEM}@g"             "${submitfile}" 

 # remove lumi mask for mc
 if [ ${dodata} = false ]
 then
     sed -i "/config.Data.lumiMask/d" "${submitfile}"
 fi

 # submit the jobs
 if [ ${dosubmit} = true ]
 then
  pushd ${thesubdir} > /dev/null
  python ${submitfile}
  popd > /dev/null
 fi

done

# end the timer
END=$(date +%s);
printf "\nStarted at ${START}\n"
printf "Ended at   ${END}\n\n"

