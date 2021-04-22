<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="RvRContribution" version="1.0.0RC13" date="2021-04-21" >
    <VersionSettings gameVersion="1.4.8" windowsVersion="1.40" savedVariablesVersion="1.50" />

		<Author name="Idrinth"/>

		<Description text="Tracks all known sources of contribution" />
		<Dependencies>
			<Dependency name="LibSlash" optional="true" />
		</Dependencies>
		<Files>
			<File name="window.xml" />
            <File name="rvr-contribution.lua" />
		</Files>
		<OnInitialize>
            <CallFunction name="RvRContribution.OnInitialize" />
		</OnInitialize>
		<OnUpdate>
            <CallFunction name="RvRContribution.OnUpdateNotification"/>
            <CallFunction name="RvRContribution.OnUpdatePQ"/>
		</OnUpdate>
		<SavedVariables>
			<SavedVariable name="RvRContribution.Zones"/>
			<SavedVariable name="RvRContribution.Config"/>
		</SavedVariables>
		<WARInfo>
			<Categories>
				<Category name="OTHER"/>
			</Categories>
		</WARInfo>

	</UiMod>
</ModuleFile>
