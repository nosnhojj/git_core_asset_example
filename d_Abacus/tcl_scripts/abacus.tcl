package provide abacus 0.1
set _DEBUG 1

namespace eval abacus {
    namespace export connect disconnect start stop loadConfig getResults

    # some initialization tasks
    lappend auto_path "c:/abacus 5000/6.10/tcl/apiclasses"
    package require Itcl
    package require tdom
    package require tclreadyapi
    wm withdraw . ;# get rid of annoying tk base window
    ::aba::ApiApplication app
    ::aba::ApiReports report
    ::aba::ApiTest test
    ::aba::ApiSystemInformation sysinfo
    
    # set up namespace variables
    variable tempDir
    variable resultFileName
    variable envFileName

    proc connect { ipAddress } {
        app Enter localhost
        createTemp
        set retVal [sysinfo SetConnection $ipAddress ""]
        return $retVal
    }

    proc disconnect {} {
        set retVal [app Exit]
        return $retVal
    }

    proc start {} {
        set retVal [test Start]
        return $retVal
    }

    proc stop {} {
        set retVal [test Stop]
        return $retVal
    }

    proc loadConfig { envFileName } {
        set ::abacus::envFileName $envFileName
        set ::abacus::resultFileName [getResultFileName $envFileName]
        app Load "$envFileName"
        set retVal [report GetRGEConfig]
        return $retVal
    }

    proc getResults {} {
        report Generate
        #puts "temporarily storing the results file in $::abacus::tempDir"
        set status [report Download $::abacus::tempDir]
        #puts "$status"
        if {$status eq "OK"} {
            set resFile [open [file join $::abacus::tempDir \
                $::abacus::resultFileName] r]
            set resultsContent [read $resFile]
            close $resFile
            deleteTemp
            return $resultsContent
        } else {
            return "report download failed"
        }
    }

    proc createTemp { {tempDir "/abacus_temp"} } {
        set ::abacus::tempDir $tempDir
        file mkdir $tempDir
    }

    proc deleteTemp {} {
        file delete -force $::abacus::tempDir
    }

    proc getResultFileName { envFileName } {
        set baseName [lindex [split $envFileName "."] 0]
        set suffix ".xml"
        set counter "_001"
        return "$baseName$counter$suffix"
    }
}
