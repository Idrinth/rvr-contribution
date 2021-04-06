<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="RvRContribution" version="1.0.0" date="2021-04-04" >
    <VersionSettings gameVersion="1.4.8" windowsVersion="1.40" savedVariablesVersion="1.50" />

		<Author name="Idrinth"/>

		<Description text="" />
		<Files>
			<File name="window.xml" />
            <File name="rvr-contribution.lua" />
		</Files>
		<OnInitialize>
            <CallFunction name="RvRContribution.OnInitialize" />
		</OnInitialize>
		<OnUpdate>
            <CallFunction name="RvRContribution.OnUpdateNote"/>
            <CallFunction name="RvRContribution.OnUpdateNotification"/>
            <CallFunction name="RvRContribution.OnUpdatePQ"/>
		</OnUpdate>
		<WARInfo>
			<Categories>
				<Category name="OTHER"/>
			</Categories>
		</WARInfo>

	</UiMod>
</ModuleFile>
