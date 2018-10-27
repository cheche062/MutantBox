f:
cd F:\h5_release\sn
svn update
svn merge http://10.8.188.3:8081/svn/BattleSpace/mutantbox/h5/release/dev

cd F:\h5_release\swn
svn update
svn merge http://10.8.188.3:8081/svn/BattleSpace/mutantbox/h5/release/dev

rem cd F:\h5_release
rem cd update 
rem svn commit -m "New Version"
pause