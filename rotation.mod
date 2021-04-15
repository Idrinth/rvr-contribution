<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">   
  <UiMod name="Rotation" version="1.0.0" date="2021-03-08" >
    <Author name="Idrinth"/>
    <Description text="Automatically anounces rotation timers" />      
    <VersionSettings gameVersion="1.4.8" />      
    <Dependencies>         
      <Dependency name="EA_ChatWindow" />
      <Dependency name="LibSlash" />
      <Dependency name="AutoChannel" />
    </Dependencies>             
    <Files>         
      <File name="rotation.lua" />
      <File name="window.xml" />
    </Files>      
    <SavedVariables/>
    <OnInitialize>
      <CallFunction name="Rotation.OnInitialize" />
    </OnInitialize>
    <OnUpdate>
      <CallFunction name="Rotation.OnUpdate" />
    </OnUpdate>
    <OnShutdown/>
  </UiMod>
</ModuleFile>