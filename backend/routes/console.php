<?php

use Illuminate\Support\Facades\Schedule;

Schedule::command('subscriptions:process-expiring')->daily();
