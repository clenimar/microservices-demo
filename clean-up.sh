#!/bin/bash

set -e

# Deploy services.
for service in adservice cartservice checkoutservice currencyservice emailservice frontend paymentservice productcatalogservice recommendationservice shippingservice redis-cart ; do

    # Remove old versions of the same chart.
    helm delete $service || echo "Failed to delete ""$service"". Continuing anyway..."

done

