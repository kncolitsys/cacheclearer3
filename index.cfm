<!---
LICENSE 
Copyright 2008-2010 Raymond Camden

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.


If you find this app worthy, I have a Amazon wish list set up (www.amazon.com/o/registry/2TCL1D08EZEYE ). 

Please see readme.txt for latest updates.
--->

<!--- tip by Yaron Kohn --->
<cfset cookie.CFADMIN_LASTPAGE_ADMIN = cgi.SCRIPT_NAME>

<cfparam name="cookie.lastpaths" default="">

<cfinclude template="../header.cfm">

<cfparam name="form.cachefile" default="">
<cfparam name="form.recursedir" type="boolean" default="no">

<h2 class="pageHeader">
Cache Clearer
</h2>

Enter either a single directory or a list of files to be removed from the trusted template cache.  The 'Recurse directory' option is only applied if a single directory is passed.
<br /><br />

<cfoutput>
<form name="cacheForm" action="#cgi.script_name#" method="post">
<strong>Single directory or list of files:</strong><br />
	<textarea cols="65" rows="8" name="cachefile" id="cachefile">#form.cachefile#</textarea><br />
	<cfif listLen(cookie.lastpaths)>
	<select name="cachefiledd" onChange="document.getElementById('cachefile').value=this.options[this.selectedIndex].value">
		<option value="">Previous Paths:</option>
		<cfloop index="lp" list="#cookie.lastpaths#">
			<option value="#lp#">#lp#</option>
		</cfloop>
	</select><br/>
	</cfif>
	<input type="checkbox" name="recursedir" value="yes" <cfif form.recursedir>checked="checked"</cfif> > <strong>Recurse directory</strong><br />
	<br />
	<input type="submit" value="Clear File(s)/Folder from Template Cache">
</form>
</cfoutput>

<cfinvoke component="cfide.adminapi.runtime" method="getCacheProperty" propertyName="TrustedCache" returnVariable="TrustedCache">
<cfif TrustedCache EQ "NO">
	<script type="text/javascript">
	formElements = cacheForm.elements;

	for( i=0; i < formElements.length; i++)
	{
		formElements[i].disabled = 'disabled';
	}

	cacheForm.cachefile.value='Trusted Cache is OFF.';
	</script>
</cfif> 

<cfif len(trim(form.cachefile))>
	<cfset form.cachefile = trim(form.cachefile)>
	
	<!--- detect folder versus file --->
	<cfset workingFileList = "">
	<cfset badFileList = "">
	
	<cfif find(",", form.cachefile)>
		<!--- Assume we were sent a list of files. --->
		<cfloop list="#form.cachefile#" index="oneFile">
			<cfif fileExists(oneFile)>
				<cfset workingFileList = listAppend(workingFileList, oneFile)>
			<cfelse>
				<cfset badFileList = listAppend(badFileList, oneFile)>
			</cfif>
		</cfloop>
	<cfelse>
		<cfif fileExists(form.cachefile)>
			<cfset workingFileList = listAppend(workingFileList, form.cachefile)>
		<cfelseif directoryExists(form.cachefile)>
			<cfdirectory directory="#form.cachefile#" name="files" recurse="#form.recursedir#" filter="*.cfm|*.cfc">
			<cfloop query="files">
				<cfset workingFileList = listAppend(workingFileList, directory & "/" & name)>
			</cfloop>
		<cfelse>
			<cfset badFileList = form.cachefile>
		</cfif>
	</cfif>
 
	<cfif badFileList NEQ "">
		<cfoutput>
			<p>
				<strong style="color:red">The following were not found:</strong><br />
				<ul>
					<cfloop index="f" list="#badFileList#">
						<li>#f#</li>
					</cfloop>
				</ul>
			</p>
		</cfoutput>
	</cfif>

	<cfif workingFileList NEQ "">
		<cfoutput>
			<p>
				<strong>Clearing the following file(s) from the template cache:</strong><br />
				<ul>
					<cfloop index="f" list="#workingFileList#">
						<li>#f#</li>
					</cfloop>
				</ul>
			</p>
		</cfoutput>
		<cfinvoke component="cfide.adminapi.runtime" method="clearTrustedCache" templateList="#workingFileList#">

		<!--- add to cookie --->
		<cfif not listFindNoCase(cookie.lastpaths, form.cachefile)>
			<cfset cookie.lastpaths = listPrepend(cookie.lastpaths, form.cachefile)>
			<cfif listlen(cookie.lastpaths) gt 5>
				<cfset cookie.lastpaths = listDeleteAt(cookie.lastpaths, 6)>
			</cfif>
		</cfif>
		
	</cfif>

</cfif>

<cfinclude template="../footer.cfm">

